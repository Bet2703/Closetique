import Foundation

class LlamaGroqAPI {
    static let apiKey = APIKeys.LLamaGroq
    
    static let endpoint = "https://api.groq.com/openai/v1/chat/completions"

    /// Genera una combinazione di 3/4 capi, restituendo i loro id separati da `;` + descrizione separata da `|`
    static func generateOutfitCombo(
        from items: [ClothingItem],
        targetStyle: String,
        completion: @escaping (String?) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            completion(nil)
            return
        }

        // Serializza le variabili rilevanti di ciascun capo
        let itemDescriptions = items.map {
            """
            id: \($0.id.uuidString), category: \($0.category), domColor: \($0.domColor ?? "N/A"), details: \($0.details ?? "N/A"), style: \($0.style)
            """
        }.joined(separator: "\n")

        // Prompt istruttivo per la formattazione richiesta e lo stile
        let userPrompt =
        """
        Questi sono i capi disponibili, ognuno ha id, category, domColor, details, style:
        \(itemDescriptions)
        Lo stile target per l'outfit è: "\(targetStyle)"
        Scegli una combinazione di 3 o 4 capi diversi che insieme creino un outfit coerente con lo stile target.
        Restituisci SOLO in questo formato:
        <id1>;<id2>;<id3>[;<id4>] | <descrizione creativa e sintetica dell'outfit>

        Nessuna spiegazione, nessun testo aggiuntivo. Solo la risposta nel formato richiesto.
        """

        let payload: [String: Any] = [
            "model": "llama3-70b-8192", // Puoi cambiare modello se vuoi
            "messages": [
                [
                    "role": "user",
                    "content": userPrompt
                ]
            ],
            "max_tokens": 200
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
