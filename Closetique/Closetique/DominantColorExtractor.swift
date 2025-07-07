import UIKit

struct KMeansColorExtractor {
    /// Estrae il colore dominante da una UIImage usando K-means in spazio LAB
    static func extractDominantColor(
        from image: UIImage,
        clusterCount k: Int = 5,
        minSaturation: CGFloat = 0.15,
        excludedBrightnessRange: ClosedRange<CGFloat> = 0.05...0.95
    ) -> String? {
        guard let cgImage = image.resized(to: CGSize(width: 100, height: 100))?.cgImage,
              let data = cgImage.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data)
        else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4

        var pointsLAB: [[CGFloat]] = []
        var pixelsRGB: [[CGFloat]] = []

        for y in 0..<height {
            for x in 0..<width {
                let idx = (y * width + x) * bytesPerPixel
                let r = CGFloat(ptr[idx]) / 255.0
                let g = CGFloat(ptr[idx+1]) / 255.0
                let b = CGFloat(ptr[idx+2]) / 255.0
                // Filtro: escludi pixel troppo chiari/scuri e poco saturi
                let hsv = rgbToHSV(r: r, g: g, b: b)
                if hsv.s < minSaturation { continue }
                if excludedBrightnessRange.contains(hsv.v) { continue }
                let lab = rgbToLab(r: r, g: g, b: b)
                pointsLAB.append(lab)
                pixelsRGB.append([r, g, b])
            }
        }
        guard !pointsLAB.isEmpty else { return nil }
        // K-means in LAB
        let clusters = kMeans(points: pointsLAB, k: k, maxIterations: 16)
        // Trova il cluster più numeroso (e non troppo vicino a bianco/nero)
        let dominantLAB = clusters.max { $0.value.count < $1.value.count }?.key
        guard let domLAB = dominantLAB else { return nil }
        let domRGB = labToRGB(l: domLAB[0], a: domLAB[1], b: domLAB[2])
        let hex = String(format: "#%02X%02X%02X", Int(domRGB.r*255), Int(domRGB.g*255), Int(domRGB.b*255))
        return hex
    }
    
    // MARK: - K-means clustering in LAB
    private static func kMeans(points: [[CGFloat]], k: Int, maxIterations: Int) -> [ [CGFloat] : [[CGFloat]] ] {
        var centroids = Array(points.shuffled().prefix(k))
        var clusters: [ [CGFloat] : [[CGFloat]] ] = [:]
        for _ in 0..<maxIterations {
            clusters = [:]
            for p in points {
                let nearest = centroids.min(by: { distanceLAB($0, p) < distanceLAB($1, p) })!
                clusters[nearest, default: []].append(p)
            }
            let newCentroids = clusters.values.map { cluster -> [CGFloat] in
                let count = CGFloat(cluster.count)
                let l = cluster.reduce(0) { $0 + $1[0] } / count
                let a = cluster.reduce(0) { $0 + $1[1] } / count
                let b = cluster.reduce(0) { $0 + $1[2] } / count
                return [l, a, b]
            }
            if newCentroids == centroids { break }
            centroids = newCentroids
        }
        // Ricostruisci clusters rispetto ai centroidi finali
        clusters = [:]
        for p in points {
            let nearest = centroids.min(by: { distanceLAB($0, p) < distanceLAB($1, p) })!
            clusters[nearest, default: []].append(p)
        }
        return clusters
    }

    // MARK: - Spazio colore
    private static func rgbToHSV(r: CGFloat, g: CGFloat, b: CGFloat) -> (h: CGFloat, s: CGFloat, v: CGFloat) {
        let mx = max(r, g, b), mn = min(r, g, b)
        let v = mx
        let d = mx - mn
        let s = mx == 0 ? 0 : d / mx
        var h: CGFloat = 0
        if d != 0 {
            if mx == r {
                h = (g - b) / d + (g < b ? 6 : 0)
            } else if mx == g {
                h = (b - r) / d + 2
            } else {
                h = (r - g) / d + 4
            }
            h /= 6
        }
        return (h, s, v)
    }

    // Conversione RGB -> LAB (D65)
    private static func rgbToLab(r: CGFloat, g: CGFloat, b: CGFloat) -> [CGFloat] {
        func pivot(_ n: CGFloat) -> CGFloat {
            return n > 0.008856 ? pow(n, 1.0/3.0) : (7.787 * n) + (16.0 / 116.0)
        }
        // sRGB -> XYZ
        func f(_ c: CGFloat) -> CGFloat {
            return (c > 0.04045) ? pow((c + 0.055) / 1.055, 2.4) : c / 12.92
        }
        let R = f(r), G = f(g), B = f(b)
        let X = (R * 0.4124 + G * 0.3576 + B * 0.1805) / 0.95047
        let Y = (R * 0.2126 + G * 0.7152 + B * 0.0722) / 1.00000
        let Z = (R * 0.0193 + G * 0.1192 + B * 0.9505) / 1.08883
        let x = pivot(X), y = pivot(Y), z = pivot(Z)
        let l = (116.0 * y) - 16.0
        let a = 500.0 * (x - y)
        let b = 200.0 * (y - z)
        return [l,a,b]
    }
    // LAB -> RGB
    private static func labToRGB(l: CGFloat, a: CGFloat, b: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let y = (l + 16.0) / 116.0
        let x = a / 500.0 + y
        let z = y - b / 200.0
        func invPivot(_ n: CGFloat) -> CGFloat {
            let n3 = pow(n,3)
            return n3 > 0.008856 ? n3 : (n - 16.0/116.0)/7.787
        }
        let X = invPivot(x) * 0.95047
        let Y = invPivot(y) * 1.00000
        let Z = invPivot(z) * 1.08883
        func g(_ t: CGFloat) -> CGFloat {
            return t > 0.0031308 ? 1.055 * pow(t, 1/2.4) - 0.055 : 12.92 * t
        }
        let R = g(X *  3.2406 + Y * -1.5372 + Z * -0.4986)
        let G = g(X * -0.9689 + Y *  1.8758 + Z *  0.0415)
        let B = g(X *  0.0557 + Y * -0.2040 + Z *  1.0570)
        return (min(max(R,0),1), min(max(G,0),1), min(max(B,0),1))
    }
    private static func distanceLAB(_ a: [CGFloat], _ b: [CGFloat]) -> CGFloat {
        let dl = a[0] - b[0]
        let da = a[1] - b[1]
        let db = a[2] - b[2]
        return sqrt(dl*dl + da*da + db*db)
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
