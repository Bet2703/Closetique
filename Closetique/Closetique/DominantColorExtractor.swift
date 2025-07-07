import UIKit

struct KMeansColorExtractor {
    static func debugCentralKMeans(
        from image: UIImage,
        centralPortion: CGFloat = 0.4,
        clusterCount k: Int = 4
    ) -> String? {
        let thumbSize = CGSize(width: 100, height: 100)
        guard let thumb = image.resized(to: thumbSize),
              let cgImage = thumb.cgImage,
              let data = cgImage.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data)
        else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4

        let centralW = Int(CGFloat(width) * centralPortion)
        let centralH = Int(CGFloat(height) * centralPortion)
        let startX = (width - centralW) / 2
        let startY = (height - centralH) / 2

        print("---- Primi 10 pixel centrali ----")
        var printed = 0
        var pointsLAB: [[CGFloat]] = []
        let totalCentral = centralW * centralH
        for y in startY..<(startY + centralH) {
            for x in startX..<(startX + centralW) {
                let idx = (y * width + x) * bytesPerPixel
                let b = CGFloat(ptr[idx]) / 255.0
                let g = CGFloat(ptr[idx+1]) / 255.0
                let r = CGFloat(ptr[idx+2]) / 255.0
                let isNearlyWhite = (r > 0.98 && g > 0.98 && b > 0.98)
                let isNearlyBlack = (r < 0.02 && g < 0.02 && b < 0.02)
                if !isNearlyWhite && !isNearlyBlack {
                    if printed < 10 {
                        print("Central pixel #\(printed+1): R=\(Int(r*255)), G=\(Int(g*255)), B=\(Int(b*255)) [RAW: \(ptr[idx]), \(ptr[idx+1]), \(ptr[idx+2]), \(ptr[idx+3])]")
                        printed += 1
                    }
                    pointsLAB.append(rgbToLab(r: r, g: g, b: b))
                }
            }
        }
        if pointsLAB.count < Int(Double(totalCentral) * 0.05) {
            pointsLAB = []
            printed = 0
            for y in startY..<(startY + centralH) {
                for x in startX..<(startX + centralW) {
                    let idx = (y * width + x) * bytesPerPixel
                    let b = CGFloat(ptr[idx]) / 255.0
                    let g = CGFloat(ptr[idx+1]) / 255.0
                    let r = CGFloat(ptr[idx+2]) / 255.0
                    if printed < 10 {
                        print("Central pixel (nofilter) #\(printed+1): R=\(Int(r*255)), G=\(Int(g*255)), B=\(Int(b*255)) [RAW: \(ptr[idx]), \(ptr[idx+1]), \(ptr[idx+2]), \(ptr[idx+3])]")
                        printed += 1
                    }
                    pointsLAB.append(rgbToLab(r: r, g: g, b: b))
                }
            }
        }
        guard !pointsLAB.isEmpty else {
            print("Nessun pixel utile trovato nella zona centrale!")
            return nil
        }
        let clusters = kMeans(points: pointsLAB, k: k, maxIterations: 16)
        let sorted = clusters.sorted { $0.value.count > $1.value.count }
        for (i, cluster) in sorted.enumerated() {
            let rgb = labToRGB(l: cluster.key[0], a: cluster.key[1], b: cluster.key[2])
            let hex = String(format: "#%02X%02X%02X", Int(rgb.r*255), Int(rgb.g*255), Int(rgb.b*255))
            print("Cluster \(i+1): HEX=\(hex), count=\(cluster.value.count)")
        }

        // PRIVILEGIA QUALSIASI CLUSTER COLORATO
        let colorThreshold: CGFloat = 0.25 // minima saturazione per essere "colorato"
        let brightnessMin: CGFloat = 0.2   // evita neri quasi puri
        let brightnessMax: CGFloat = 0.95  // evita bianchi quasi puri

        var bestColorCluster: ([CGFloat], Int)? = nil
        for (key, value) in sorted {
            let rgb = labToRGB(l: key[0], a: key[1], b: key[2])
            let hsv = rgbToHSV(r: rgb.r, g: rgb.g, b: rgb.b)
            if hsv.s > colorThreshold && hsv.v > brightnessMin && hsv.v < brightnessMax {
                if bestColorCluster == nil || value.count > bestColorCluster!.1 {
                    bestColorCluster = (key, value.count)
                }
            }
        }
        let domLAB: [CGFloat]
        if let best = bestColorCluster {
            domLAB = best.0
            print("Scelto cluster più colorato (s>\(colorThreshold)): \(domLAB)")
        } else if let first = sorted.first?.key {
            domLAB = first
            print("Nessun cluster colorato, scelgo il più numeroso (probabilmente grigio/nero/bianco)")
        } else {
            return nil
        }

        let domRGB = labToRGB(l: domLAB[0], a: domLAB[1], b: domLAB[2])
        let hex = String(format: "#%02X%02X%02X", Int(domRGB.r*255), Int(domRGB.g*255), Int(domRGB.b*255))
        print("Dominant HEX (central KMeans):", hex)
        return hex
    }

    // --- KMeans e conversioni come prima ---
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
        clusters = [:]
        for p in points {
            let nearest = centroids.min(by: { distanceLAB($0, p) < distanceLAB($1, p) })!
            clusters[nearest, default: []].append(p)
        }
        return clusters
    }
    private static func rgbToLab(r: CGFloat, g: CGFloat, b: CGFloat) -> [CGFloat] {
        func pivot(_ n: CGFloat) -> CGFloat {
            return n > 0.008856 ? pow(n, 1.0/3.0) : (7.787 * n) + (16.0 / 116.0)
        }
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
        return [l, a, b]
    }
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
    private static func rgbToHSV(r: CGFloat, g: CGFloat, b: CGFloat) -> (h: CGFloat, s: CGFloat, v: CGFloat) {
        let maxVal = max(r,g,b)
        let minVal = min(r,g,b)
        let v = maxVal
        let delta = maxVal - minVal
        let s = (maxVal == 0) ? 0 : delta / maxVal
        var h: CGFloat = 0
        if delta != 0 {
            if maxVal == r { h = (g - b) / delta }
            else if maxVal == g { h = 2 + (b - r) / delta }
            else { h = 4 + (r - g) / delta }
            h *= 60
            if h < 0 { h += 360 }
        }
        return (h, s, v)
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
