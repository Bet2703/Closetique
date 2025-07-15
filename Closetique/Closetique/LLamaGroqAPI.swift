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
            print("DEBUG: Endpoint URL non valida.")
            completion(nil)
            return
        }

        let itemDescriptions = items.map {
            """
            id: \($0.id.uuidString), category: \($0.category), domColor: \($0.domColor ?? "N/A"), details: \($0.details ?? "N/A"), style: \($0.style)
            """
        }.joined(separator: "\n")

        let userPrompt =
        """
        Questi sono i capi disponibili, ognuno ha id, category, domColor, details, style:
        \(itemDescriptions)
        Lo stile target per l'outfit è: "\(targetStyle)"
        Scegli una combinazione di N capi diversi (dove N rappresenta il numero di capi, può essere superiore a 5/6 ma non deve mai essere inferiore a 2) che insieme creino un outfit coerente con lo stile target.
        Restituisci SOLO in questo formato e con almeno 2 capi OBBLIGATORIAMENTE:
        <id1>;<id2>;<id3>;... | <descrizione creativa e sintetica dell'outfit, inserisci un voto nel formato X/10 (es. 8/10, 7.5/10) e motivazione dell'abbinamento anche attraverso colori>

        Nessuna spiegazione, nessun testo aggiuntivo. Solo la risposta nel formato richiesto.
        """

        let payload: [String: Any] = [
            "model": "llama3-70b-8192",
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
            print("DEBUG: Errore serializzazione payload \(error)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("DEBUG: Errore di rete: \(error.localizedDescription)")
            }
            if let response = response as? HTTPURLResponse {
                print("DEBUG: Codice HTTP: \(response.statusCode)")
            }
            if let data = data, let raw = String(data: data, encoding: .utf8) {
                print("DEBUG: Risposta raw dalla API:\n\(raw)")
            }
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    print("DEBUG: Contenuto generato dalla AI: \(content)")
                    let parts = content.components(separatedBy: "|")
                    if parts.count != 2 {
                        print("DEBUG: ⚠️ Formato NON valido. La risposta NON contiene un pipe '|' per separare id e descrizione.")
                    }
                    completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    print("DEBUG: Parsing JSON fallito o campo mancante.")
                    completion(nil)
                }
            } catch {
                print("DEBUG: Errore parsing JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
