import UIKit

// Estensione per ridimensionare le immagini facilmente
extension UIImage {
    /// Ridimensiona l'immagine alla larghezza specificata mantenendo le proporzioni.
    func resized(toWidth width: CGFloat) -> UIImage? {
        let scale = width / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: width, height: newHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

class GeminiVisionAnalyzer {
    static let shared = GeminiVisionAnalyzer()

    private var endpoint: URL {
        return URL(string: "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=\(APIKeys.geminiVision)")!
    }

    /// Analizza tipologia, vestibilità e dettaglio distintivo principale del capo visibile
    func analyzeFit(image: UIImage, completion: @escaping (String?) -> Void) {
        let prompt = """
        Scrivi la categoria specifica del capo, la macrocategoria di appartenenza (scegliendo obbligatoriamente solo tra queste classi: Maglie, Pantaloni, Giacche, Scarpe, Accessori, Extra), lo stile (casual, elegante, urban, gotic, relaxed...), il colore principale e nella descrizione sia la vestibilità (es: oversize, regular, slim, ecc.) sia un dettaglio visivo ben riconoscibile (es: grafica, righe, strappi, ecc.).

        Esegui il mapping automatico dei capi:
        - "cappello", "berretto", "bucket hat", "cuffia", "beanie", ecc. → Accessori
        - "maglia", "top", "t-shirt", "camicia", "felpa", ecc. → Maglie
        - "jeans", "pantalone", "shorts", "leggings", ecc. → Pantaloni
        - "giacca", "blazer", "cappotto", "parka", ecc. → Giacche
        - "sneakers", "scarpe", "stivali", "sandali", ecc. → Scarpe
        - Oggetti non indossabili o non riconducibili alle precedenti categorie → Extra

        Rispondi in una sola riga, separando i valori con il carattere | (pipe), nel formato:

        Capo|Macrocategoria|Stile|Colore|Descrizione

        Esempi:
        maglia|Maglie|casual|bianco|oversize, righe bianche e nere
        jeans|Pantaloni|urban|blu|slim, strappi
        giacca|Giacche|elegante|nero|regular, doppiopetto
        sneakers|Scarpe|gotic|nero|platform, suola alta
        cappello|Accessori|relaxed|rosso|regular, logo frontale
        cintura|Accessori|relaxed|marrone|regular, fibbia grande
        zaino|Extra|urban|nero|grande, tasche multiple

        Se non vedi nessun capo, rispondi: non determinabile|||| (e lascia gli altri campi vuoti).
        Non aggiungere altro testo.
        """
        print("Prompt inviato a GeminiVisionAnalyzer: \(prompt)")
        analyze(image: image, prompt: prompt) { fit in
            guard let fit = fit else {
                completion(nil)
                return
            }
            // Prendi solo la prima riga, massimo 7 parole
            let fitShort = fit.components(separatedBy: .newlines).first?
                .components(separatedBy: " ")
                .prefix(7).joined(separator: " ")
            print("GeminiVisionAnalyzer risposta (analyzeFit): \(fitShort ?? "")")
            completion(fitShort)
        }
    }

    /// Funzione interna, non va usata direttamente dall'esterno
    private func analyze(image: UIImage, prompt: String, completion: @escaping (String?) -> Void) {
        print("Prompt inviato a GeminiVisionAnalyzer: \(prompt)")
        // Riduci la dimensione dell'immagine a 600px di larghezza e qualità JPEG al 40%
        let resizedImage = image.resized(toWidth: 600) ?? image
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }
        print("Dimensione immagine JPEG inviata: \(Double(imageData.count) / 1024.0) KB")

        let base64Image = imageData.base64EncodedString()

        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ]
        ]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Errore di rete GeminiVisionAnalyzer: \(error)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("Nessun dato ricevuto da GeminiVisionAnalyzer")
                completion(nil)
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let content = candidates.first?["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let text = parts.first?["text"] as? String {
                print("GeminiVisionAnalyzer risposta ricevuta: \(text)")
                completion(text)
            } else {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Risposta non prevista da GeminiVisionAnalyzer: \(responseString)")
                }
                completion(nil)
            }
        }.resume()
    }
}
