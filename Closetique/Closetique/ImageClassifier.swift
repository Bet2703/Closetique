import UIKit
import Vision
import CoreML

class ImageClassifier {
    static let shared = ImageClassifier()

    private init() {}
    func dominantColorHexCentralCrop(from image: UIImage) -> String? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let extent = ciImage.extent
        let cropRect = CGRect(
            x: extent.midX - extent.width * 0.25,
            y: extent.midY - extent.height * 0.25,
            width: extent.width * 0.5,
            height: extent.height * 0.5
        )
        
        let croppedImage = ciImage.cropped(to: cropRect)
        
        let context = CIContext()
        let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: croppedImage,
            kCIInputExtentKey: CIVector(cgRect: croppedImage.extent)
        ])
        
        guard let outputImage = filter?.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())
        
        let red = bitmap[0]
        let green = bitmap[1]
        let blue = bitmap[2]
        
        return String(format: "#%02X%02X%02X", red, green, blue)
    }

    func classify(image: UIImage, completion: @escaping (ClassificationResult) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(ClassificationResult(category: "Sconosciuto", style: "NA", domColor: nil))
            return
        }

        guard let model = try? FashionClassifier_1(configuration: MLModelConfiguration()),
              let visionModel = try? VNCoreMLModel(for: model.model) else {
            completion(ClassificationResult(category: "Errore", style: "NA", domColor: nil))
            return
        }

        let request = VNCoreMLRequest(model: visionModel) { request, _ in
            var result = ClassificationResult(category: "Sconosciuto", style: "NA", domColor: nil)

            if let observations = request.results as? [VNClassificationObservation],
               let topResult = observations.first {
                let label = topResult.identifier.lowercased()

                let knownStyles = [
                    "casual", "sports", "ethnic", "formal", "party",
                    "travel", "smart casual", "home", "night", "na"
                ]

                let knownCategories = [
                    "tshirts", "shirts", "casual shoes", "watches", "sports shoes", "kurtas",
                    "tops", "handbags", "heels", "sunglasses", "flip flops", "sandals", "belts",
                    "socks", "formal shoes", "jeans", "shorts", "trousers", "flats", "dresses",
                    "sarees", "track pants", "sweatshirts", "caps", "sweaters", "ties", "jackets",
                    "innerwear vests", "kurtis", "tunics", "nightdress", "leggings", "pendant",
                    "capris", "night suits", "trunk", "skirts", "scarves", "dupatta", "stoles",
                    "duffel bag", "sports sandals", "face moisturisers", "lounge pants",
                    "camisoles", "patiala", "jeggings", "lounge shorts", "salwar", "stockings",
                    "churidar", "tracksuits", "gloves", "hair colour", "rain jacket", "swimwear",
                    "jumpsuit", "shapewear", "tights", "blazers", "headband", "robe", "hat",
                    "lounge tshirts", "suits"
                ]

                var foundStyle = "NA"
                for style in knownStyles {
                    if label.contains(style) {
                        foundStyle = style.capitalized
                        break
                    }
                }

                var foundCategory = "Sconosciuto"
                for category in knownCategories {
                    if label.contains(category) {
                        foundCategory = category.capitalized
                        break
                    }
                }

                if let hex = self.dominantColorHexCentralCrop(from: image) {
                    ColorConverter.getColorName(from: hex) { colorName in
                        let finalColor = colorName ?? hex
                        DispatchQueue.main.async {
                            let result = ClassificationResult(category: foundCategory, style: foundStyle, domColor: finalColor)
                            completion(result)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        let result = ClassificationResult(category: foundCategory, style: foundStyle, domColor: nil)
                        completion(result)
                    }
                }

            }

            DispatchQueue.main.async {
                completion(result)
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global().async {
            try? handler.perform([request])
        }
    }
}
