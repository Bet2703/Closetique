//
//  ImageClassifier.swift
//  Closetique
//
import UIKit

/// Gestisce il riempimento dei parametri dei capi durante il parsing di GeminiVisionAnalyzer
class ImageClassifier {
    static let shared = ImageClassifier()

    func classify(image: UIImage, completion: @escaping (ClassificationResult) -> Void) {
        GeminiVisionAnalyzer.shared.analyzeFit(image: image) { geminiFit in
            var capo = "Sconosciuto"
            var macrocategoria = "NA"
            var stile = "NA"
            var colore = "NA"
            var descrizione = "NA"
            var hexColor = "FFFFFF"
            if let text = geminiFit {
                let fields = text.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                if fields.count > 0, !fields[0].isEmpty { capo = fields[0] }
                if fields.count > 1, !fields[1].isEmpty { macrocategoria = fields[1] }
                if fields.count > 2, !fields[2].isEmpty { stile = fields[2] }
                if fields.count > 3, !fields[3].isEmpty { colore = fields[3] }
                if fields.count > 4, !fields[4].isEmpty { descrizione = fields[4] }
                if fields.count > 5, !fields[5].isEmpty { hexColor = fields[5]}
            }

            let result = ClassificationResult(
                category: capo,
                macrocategory: macrocategoria,
                style: stile,
                domColor: colore,
                details: descrizione,
                hexColor: hexColor
            )
            completion(result)
        }
    }
}
