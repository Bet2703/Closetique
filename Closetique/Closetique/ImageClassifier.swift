import UIKit
import Vision
import CoreML

class ImageClassifier {
    static let shared = ImageClassifier()

    private init() {}

    func classify(image: UIImage, completion: @escaping (ClassificationResult) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(ClassificationResult(category: "Sconosciuto", style: "NA", color: nil))
            return
        }

        guard let model = try? FashionClassifier_1(configuration: MLModelConfiguration()),
              let visionModel = try? VNCoreMLModel(for: model.model) else {
            completion(ClassificationResult(category: "Errore", style: "NA", color: nil))
            return
        }

        let request = VNCoreMLRequest(model: visionModel) { request, _ in
            var result = ClassificationResult(category: "Sconosciuto", style: "NA", color: nil)

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

                result = ClassificationResult(category: foundCategory, style: foundStyle, color: nil)
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
