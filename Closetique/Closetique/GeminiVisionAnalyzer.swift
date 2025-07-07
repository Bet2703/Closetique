import UIKit

class GeminiVisionAnalyzer {
    static let shared = GeminiVisionAnalyzer()

    private var endpoint: URL {
        return URL(string: "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=\(APIKeys.geminiVision)")!
    }

    /// Analizza tipologia, vestibilità e dettaglio distintivo principale del capo visibile
    func analyzeFit(image: UIImage, completion: @escaping (String?) -> Void) {
        let prompt = """
        Scrivi solo la tipologia, la vestibilità e un dettaglio ben riconoscibile del capo principale nell'immagine, in massimo 20 parole. Non aggiungere dettagli sulla persona o sull'ambiente. Esempi:
        - "jeans baggy con strappi"
        -"jeans "lavato""
        - "maglia aderente a righe bianche e nere"
        - "t-shirt oversize con grafica palme"
        In pratica scrivi tutto ciò di particolare che vedi del capo.
        Se non vedi nessun capo, rispondi: "non determinabile".
        Rispondi solo simile agli esempi, senza aggiungere altro.
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
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
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
