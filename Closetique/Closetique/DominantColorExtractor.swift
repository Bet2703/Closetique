import UIKit
import Vision

struct KMeansColorExtractor {
    /// Estrae il colore dominante eseguendo KMeans solo sui pixel appartenenti alla persona (segmentazione Vision).
    static func dominantColorViaSegmentation(image: UIImage, clusterCount k: Int = 4, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else { completion(nil); return }

        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .accurate
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                guard let maskPixelBuffer = request.results?.first?.pixelBuffer else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                // Ridimensiona immagine e maschera allo stesso size
                let thumbSize = CGSize(width: 100, height: 100)
                guard let thumb = image.resized(to: thumbSize) else { DispatchQueue.main.async { completion(nil) }; return }
                guard let maskImage = maskPixelBuffer.toUIImage()?.resized(to: thumbSize) else { DispatchQueue.main.async { completion(nil) }; return }
                guard let maskCG = maskImage.cgImage, let thumbCG = thumb.cgImage,
                      let data = thumbCG.dataProvider?.data, let ptr = CFDataGetBytePtr(data),
                      let maskData = maskCG.dataProvider?.data, let maskPtr = CFDataGetBytePtr(maskData) else {
                    DispatchQueue.main.async { completion(nil) }; return
                }
                let width = thumbCG.width
                let height = thumbCG.height
                var pointsLAB: [[CGFloat]] = []
                let bytesPerPixel = 4
                for y in 0..<height {
                    for x in 0..<width {
                        let idx = (y * width + x) * bytesPerPixel
                        let maskIdx = (y * width + x)
                        let maskVal = maskPtr[maskIdx]
                        guard maskVal > 127 else { continue } // Prendi solo pixel persona!
                        let b = CGFloat(ptr[idx]) / 255.0
                        let g = CGFloat(ptr[idx+1]) / 255.0
                        let r = CGFloat(ptr[idx+2]) / 255.0
                        let isNearlyWhite = (r > 0.98 && g > 0.98 && b > 0.98)
                        let isNearlyBlack = (r < 0.02 && g < 0.02 && b < 0.02)
                        if !isNearlyWhite && !isNearlyBlack {
                            pointsLAB.append(rgbToLab(r: r, g: g, b: b))
                        }
                    }
                }
                guard !pointsLAB.isEmpty else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                let clusters = kMeans(points: pointsLAB, k: k, maxIterations: 16)
                let sorted = clusters.sorted { $0.value.count > $1.value.count }
                // Log dei cluster trovati
                for (i, cluster) in sorted.enumerated() {
                    let rgb = labToRGB(l: cluster.key[0], a: cluster.key[1], b: cluster.key[2])
                    let hex = String(format: "#%02X%02X%02X", Int(rgb.r*255), Int(rgb.g*255), Int(rgb.b*255))
                    print("Cluster \(i+1): HEX=\(hex), count=\(cluster.value.count)")
                }
                // Logica di scelta cluster colorato non pelle
                let colorThreshold: CGFloat = 0.25
                let brightnessMin: CGFloat = 0.2
                let brightnessMax: CGFloat = 0.95
                func isSkinColor(h: CGFloat, s: CGFloat, v: CGFloat) -> Bool {
                    return h > 10 && h < 50 && s > 0.15 && s < 0.55 && v > 0.3 && v < 0.85
                }
                var bestColorCluster: ([CGFloat], Int)? = nil
                for (key, value) in sorted {
                    let rgb = labToRGB(l: key[0], a: key[1], b: key[2])
                    let hsv = rgbToHSV(r: rgb.r, g: rgb.g, b: rgb.b)
                    if hsv.s > colorThreshold && hsv.v > brightnessMin && hsv.v < brightnessMax && !isSkinColor(h: hsv.h, s: hsv.s, v: hsv.v) {
                        if bestColorCluster == nil || value.count > bestColorCluster!.1 {
                            bestColorCluster = (key, value.count)
                        }
                    }
                }
                if bestColorCluster == nil {
                    for (key, value) in sorted {
                        let rgb = labToRGB(l: key[0], a: key[1], b: key[2])
                        let hsv = rgbToHSV(r: rgb.r, g: rgb.g, b: rgb.b)
                        if hsv.s > colorThreshold && hsv.v > brightnessMin && hsv.v < brightnessMax {
                            bestColorCluster = (key, value.count)
                            break
                        }
                    }
                }
                let domLAB: [CGFloat]
                if let best = bestColorCluster {
                    domLAB = best.0
                } else if let first = sorted.first?.key {
                    domLAB = first
                } else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                let domRGB = labToRGB(l: domLAB[0], a: domLAB[1], b: domLAB[2])
                let hex = String(format: "#%02X%02X%02X", Int(domRGB.r*255), Int(domRGB.g*255), Int(domRGB.b*255))
                DispatchQueue.main.async { completion(hex) }
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }

    /*
    /// Estrae il colore dominante dalla porzione centrale dell'immagine, senza segmentazione Vision.
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
                    pointsLAB.append(rgbToLab(r: r, g: g, b: b))
                }
            }
        }
        if pointsLAB.count < Int(Double(totalCentral) * 0.05) {
            pointsLAB = []
            for y in startY..<(startY + centralH) {
                for x in startX..<(startX + centralW) {
                    let idx = (y * width + x) * bytesPerPixel
                    let b = CGFloat(ptr[idx]) / 255.0
                    let g = CGFloat(ptr[idx+1]) / 255.0
                    let r = CGFloat(ptr[idx+2]) / 255.0
                    pointsLAB.append(rgbToLab(r: r, g: g, b: b))
                }
            }
        }
        guard !pointsLAB.isEmpty else { return nil }
        let clusters = kMeans(points: pointsLAB, k: k, maxIterations: 16)
        let sorted = clusters.sorted { $0.value.count > $1.value.count }

        // Logica di scelta cluster colorato non pelle
        let colorThreshold: CGFloat = 0.25
        let brightnessMin: CGFloat = 0.2
        let brightnessMax: CGFloat = 0.95
        func isSkinColor(h: CGFloat, s: CGFloat, v: CGFloat) -> Bool {
            return h > 10 && h < 50 && s > 0.15 && s < 0.55 && v > 0.3 && v < 0.85
        }
        var bestColorCluster: ([CGFloat], Int)? = nil
        for (key, value) in sorted {
            let rgb = labToRGB(l: key[0], a: key[1], b: key[2])
            let hsv = rgbToHSV(r: rgb.r, g: rgb.g, b: rgb.b)
            if hsv.s > colorThreshold && hsv.v > brightnessMin && hsv.v < brightnessMax && !isSkinColor(h: hsv.h, s: hsv.s, v: hsv.v) {
                if bestColorCluster == nil || value.count > bestColorCluster!.1 {
                    bestColorCluster = (key, value.count)
                }
            }
        }
        if bestColorCluster == nil {
            for (key, value) in sorted {
                let rgb = labToRGB(l: key[0], a: key[1], b: key[2])
                let hsv = rgbToHSV(r: rgb.r, g: rgb.g, b: rgb.b)
                if hsv.s > colorThreshold && hsv.v > brightnessMin && hsv.v < brightnessMax {
                    bestColorCluster = (key, value.count)
                    break
                }
            }
        }
        let domLAB: [CGFloat]
        if let best = bestColorCluster {
            domLAB = best.0
        } else if let first = sorted.first?.key {
            domLAB = first
        } else {
            return nil
        }
        let domRGB = labToRGB(l: domLAB[0], a: domLAB[1], b: domLAB[2])
        let hex = String(format: "#%02X%02X%02X", Int(domRGB.r*255), Int(domRGB.g*255), Int(domRGB.b*255))
        return hex
    }
    */

    // KMeans clustering per LAB
    static func kMeans(points: [[CGFloat]], k: Int, maxIterations: Int) -> [ [CGFloat] : [[CGFloat]] ] {
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
}

// --- Funzioni di conversione colori globali ---

func rgbToLab(r: CGFloat, g: CGFloat, b: CGFloat) -> [CGFloat] {
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

func labToRGB(l: CGFloat, a: CGFloat, b: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
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

func rgbToHSV(r: CGFloat, g: CGFloat, b: CGFloat) -> (h: CGFloat, s: CGFloat, v: CGFloat) {
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

func distanceLAB(_ a: [CGFloat], _ b: [CGFloat]) -> CGFloat {
    let dl = a[0] - b[0]
    let da = a[1] - b[1]
    let db = a[2] - b[2]
    return sqrt(dl*dl + da*da + db*db)
}

// Utility per convertire CVPixelBuffer in UIImage
extension CVPixelBuffer {
    func toUIImage() -> UIImage? {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }
        guard let baseAddress = CVPixelBufferGetBaseAddress(self) else { return nil }
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        if let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0),
           let cgImage = context.makeImage() {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}

// Utility resize UIImage
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
