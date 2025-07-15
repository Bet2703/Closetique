/*import UIKit
import Vision
import CoreML

class ImageClassifierOLD {
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

            let knownStyles = [
                "casual", "sports", "formal", "party",
                "travel", "smart casual", "home", "night", "na"
            ]
            let knownCategories = [
                "tshirts", "shirts", "casual shoes", "watches", "sports shoes",
                "tops", "handbags", "heels", "sunglasses", "flip flops", "sandals", "belts",
                "socks", "formal shoes", "jeans", "shorts", "trousers", "flats", "dresses",
                "track pants", "sweatshirts", "caps", "sweaters", "ties", "jackets",
                "innerwear vests", "nightdress", "leggings", "pendant",
                "capris", "night suits", "trunk", "skirts", "scarves", "stoles",
                "duffel bag", "sports sandals", "face moisturisers", "lounge pants",
                "camisoles", "jeggings", "lounge shorts", "stockings",
                "tracksuits", "gloves", "hair colour", "rain jacket", "swimwear",
                "jumpsuit", "shapewear", "tights", "blazers", "headband", "robe", "hat",
                "lounge tshirts", "suits"
            ]
            let ethnicLabels = ["salwar", "kurta", "kurti", "patiala", "saree", "churidar", "dupatta", "tunics", "ethnic"]

            var foundStyle = "NA"
            var foundCategory = "Sconosciuto"

            if let observations = request.results as? [VNClassificationObservation], !observations.isEmpty {
                let lowerLabels = observations.map { $0.identifier.lowercased() }
                print("5️⃣ [ImageClassifier] VNCoreMLRequest: labels = \(lowerLabels)")

                // Trova tutte le style e category possibili
                var foundStyles: [String] = []
                var foundCategories: [String] = []
                for label in lowerLabels {
                    for style in knownStyles {
                        if label.contains(style) {
                            foundStyles.append(style.capitalized)
                            break
                        }
                    }
                    for category in knownCategories {
                        if label.contains(category) {
                            foundCategories.append(category.capitalized)
                            break
                        }
                    }
                }
                // Trova se la prima label è etnica sia per style che per category
                let isEthnic = { (text: String) in
                    ethnicLabels.contains { text.lowercased().contains($0) }
                }
                let isFirstStyleEthnic = foundStyles.first.map(isEthnic) ?? false
                let isFirstCategoryEthnic = foundCategories.first.map(isEthnic) ?? false

                if isFirstStyleEthnic && isFirstCategoryEthnic && foundStyles.count > 1 && foundCategories.count > 1 {
                    foundStyle = foundStyles[1]
                    foundCategory = foundCategories[1]
                    print("6️⃣ [ImageClassifier] Prima label etnica. Usata la seconda: Style \(foundStyle), Category \(foundCategory)")
                } else {
                    foundStyle = foundStyles.first ?? "NA"
                    foundCategory = foundCategories.first ?? "Sconosciuto"
                    print("6️⃣ [ImageClassifier] Style trovato: \(foundStyle), Category trovata: \(foundCategory)")
                }
            } else {
                print("5️⃣ [ImageClassifier] VNCoreMLRequest: nessun risultato di classificazione")
            }

            let group = DispatchGroup()
            var domColor: String?
            var details: String?

            // Colore dominante con KMeansColorExtractor (USO CORRETTO ASINCRONO)
            group.enter()
            print("7️⃣ [ImageClassifier] Calcolo colore dominante (KMeansColorExtractor)...")
            KMeansColorExtractor.dominantColorViaSegmentation(image: image) { hex in
                print("Dominant color HEX: \(hex ?? "nil")")
                if let hex = hex {
                    ColorConverter.getColorName(from: hex) { colorName in
                        domColor = colorName ?? hex
                        print("Colore finale: \(domColor ?? "nil")")
                        group.leave()
                    }
                } else {
                    domColor = nil
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
}*/
