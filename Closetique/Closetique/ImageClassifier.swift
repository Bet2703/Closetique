import UIKit
import Vision
import CoreML

class ImageClassifier {
    static let shared = ImageClassifier()

    func classify(image: UIImage, completion: @escaping (ClassificationResult) -> Void) {
        print("1️⃣ [ImageClassifier] Inizio classificazione")

        guard let ciImage = CIImage(image: image) else {
            print("2️⃣ [ImageClassifier] Errore: Immagine non valida")
            completion(ClassificationResult(category: "Sconosciuto", style: "NA", domColor: nil, details: nil))
            return
        }

        guard let model = try? FashionClassifier_1(configuration: MLModelConfiguration()),
              let visionModel = try? VNCoreMLModel(for: model.model) else {
            print("3️⃣ [ImageClassifier] Errore: Modello ML non disponibile")
            completion(ClassificationResult(category: "Errore", style: "NA", domColor: nil, details: nil))
            return
        }

        let request = VNCoreMLRequest(model: visionModel) { request, _ in
            print("4️⃣ [ImageClassifier] Eseguito VNCoreMLRequest")
            var foundStyle = "NA"
            var foundCategory = "Sconosciuto"
            if let observations = request.results as? [VNClassificationObservation],
               let topResult = observations.first {
                let label = topResult.identifier.lowercased()
                print("5️⃣ [ImageClassifier] VNCoreMLRequest: topResult = \(label)")

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
                for style in knownStyles {
                    if label.contains(style) {
                        foundStyle = style.capitalized
                        break
                    }
                }
                for category in knownCategories {
                    if label.contains(category) {
                        foundCategory = category.capitalized
                        break
                    }
                }
                print("6️⃣ [ImageClassifier] Style trovato: \(foundStyle), Category trovata: \(foundCategory)")
            } else {
                print("5️⃣ [ImageClassifier] VNCoreMLRequest: nessun risultato di classificazione")
            }

            let group = DispatchGroup()
            var domColor: String?
            var details: String?

            // Colore dominante con KMeansColorExtractor
            group.enter()
            print("7️⃣ [ImageClassifier] Calcolo colore dominante (KMeansColorExtractor)...")
            DispatchQueue.global(qos: .userInitiated).async {
                let hex = KMeansColorExtractor.extractDominantColor(from: image)
                print("Dominant color HEX: \(hex ?? "nil")")
                ColorConverter.getColorName(from: hex ?? "#CCCCCC") { colorName in
                    domColor = colorName ?? hex
                    print("Colore finale: \(domColor ?? "nil")")
                    group.leave()
                }
            }

            // Gemini Vision: chiama la funzione ultra short SENZA passare un prompt custom
            group.enter()
            print("🔟 [ImageClassifier] Chiamata GeminiVisionAnalyzer (ultra short)")
            GeminiVisionAnalyzer.shared.analyzeFit(image: image) { geminiFit in
                print("1️⃣1️⃣ [ImageClassifier] GeminiVisionAnalyzer risposta ricevuta (ultra short): \(geminiFit ?? "nil")")
                details = geminiFit
                group.leave()
            }

            group.notify(queue: .main) {
                print("1️⃣2️⃣ [ImageClassifier] DispatchGroup completato, restituisco risultato")
                let result = ClassificationResult(
                    category: foundCategory,
                    style: foundStyle,
                    domColor: domColor,
                    details: details
                )
                completion(result)
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
                print("3️⃣ [ImageClassifier] VNImageRequestHandler eseguito con successo")
            } catch {
                print("3️⃣ [ImageClassifier] Errore durante la richiesta VNImageRequestHandler: \(error)")
                DispatchQueue.main.async {
                    completion(ClassificationResult(category: "Errore", style: "NA", domColor: nil, details: nil))
                }
            }
        }
    }
}
