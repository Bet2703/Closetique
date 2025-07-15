import UIKit
import Vision
import CoreML

class ImageClassifier {
    static let shared = ImageClassifier()

    func classify(image: UIImage, completion: @escaping (ClassificationResult) -> Void) {
        print("1️⃣ [ImageClassifier] Inizio classificazione")

        let group = DispatchGroup()
        var domColor: String?
        var details: String?
        var foundCategory: String = "Sconosciuto"
        var foundStyle: String = "NA"

        // 1. Calcolo colore dominante (KMeansColorExtractor)
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

        // 2. Gemini Vision: parsing della risposta per style e category
        group.enter()
        print("🔟 [ImageClassifier] Chiamata GeminiVisionAnalyzer (ultra short)")
        GeminiVisionAnalyzer.shared.analyzeFit(image: image) { geminiFit in
            print("1️⃣1️⃣ [ImageClassifier] GeminiVisionAnalyzer risposta ricevuta (ultra short): \(geminiFit ?? "nil")")
            details = geminiFit

            // --- PARSING RISPOSTA ---
            if let text = geminiFit {
                // Esempio parsing: cerca "Category: xxx" e "Style: yyy"
                let lower = text.lowercased()
                if let catRange = lower.range(of: "category:") {
                    let afterCat = lower[catRange.upperBound...]
                    let cat = afterCat.split(separator: "\n").first?.trimmingCharacters(in: .whitespacesAndNewlines)
                    foundCategory = cat?.capitalized ?? foundCategory
                }
                if let styleRange = lower.range(of: "style:") {
                    let afterStyle = lower[styleRange.upperBound...]
                    let style = afterStyle.split(separator: "\n").first?.trimmingCharacters(in: .whitespacesAndNewlines)
                    foundStyle = style?.capitalized ?? foundStyle
                }
                // Se Gemini restituisce qualcosa tipo "The item is a cardigan, casual style", puoi fare anche:
                if foundCategory == "Sconosciuto" {
                    if let card = lower.components(separatedBy: "the item is a ").last?.split(separator: ",").first {
                        foundCategory = card.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
                    }
                }
                if foundStyle == "NA" {
                    // Cerca "casual style", "formal style", ecc.
                    if let styleWord = lower.components(separatedBy: "style").first?.split(separator: ",").last {
                        foundStyle = styleWord.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
                    }
                }
            }
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
}
