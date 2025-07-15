import Foundation

class LlamaGroqAPI {
    static let apiKey = APIKeys.LLamaGroq
    static let endpoint = "https://api.groq.com/openai/v1/chat/completions"

    /// Genera una combinazione di capi, restituendo i loro id separati da `;` + descrizione separata da `|`
    static func generateOutfitCombo(
        from items: [ClothingItem],
        targetStyle: String,
        completion: @escaping (String?) -> Void
    ) {
        generateOutfitComboInternal(from: items, targetStyle: targetStyle, completion: completion, attempt: 1)
    }
    
    private static func generateOutfitComboInternal(
        from items: [ClothingItem],
        targetStyle: String,
        completion: @escaping (String?) -> Void,
        attempt: Int
    ) {
        guard let url = URL(string: endpoint) else {
            print("DEBUG: Endpoint URL non valida.")
            completion(nil)
            return
        }

        let itemDescriptions = items.map {
            """
            id: \($0.id.uuidString), category: \($0.category), domColor: \($0.domColor ?? "N/A"), details: \($0.details ?? "N/A"), style: \($0.style), macro:\($0.macrocategory)
            """
        }.joined(separator: "\n")

        let userPrompt =
        """
        Questi sono i capi disponibili, ognuno ha id, category, domColor, details, style:
        \(itemDescriptions)
        Lo stile target per l'outfit è: "\(targetStyle)"

        IMPORTANTE:
        - Scegli una combinazione di N capi diversi (N >= 2, può essere superiore a 5/6).
        - NON accoppiare 2 maglie o 2 pantaloni nello stesso outfit (salvo eccezione: camicia sopra maglia SOLO se lo stile è casual o street).
        - Se includi due maglie o due pantaloni, il voto finale dell'outfit deve essere severamente penalizzato (max 5/10) e devi scrivere nella descrizione che l'outfit non è valido perché contiene due maglie o due pantaloni e devi essere molto severo.
        - Preferisci sempre macro-categorie differenti.

        Rispondi SOLO in questo formato (nessun testo extra):
        <id1>;<id2>;<id3>;... | <descrizione creativa e sintetica dell'outfit, con voto X/10 e motivazione. Se non hai rispettato le regole, spiega l'errore nella descrizione.>
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
                    let ids = content.components(separatedBy: "|").first?
                        .split(separator: ";")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty } ?? []

                    if !isValidOutfit(items: items, ids: ids, targetStyle: targetStyle) {
                        print("DEBUG: Outfit non valido (2 maglie/pantaloni), rigenero... Tentativo \(attempt)")
                        // Limita a massimo 5 tentativi per evitare loop infinito
                        if attempt < 5 {
                            // Rigenera dopo un piccolo delay (esponenziale)
                            let delay = pow(2.0, Double(attempt))
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                generateOutfitComboInternal(from: items, targetStyle: targetStyle, completion: completion, attempt: attempt + 1)
                            }
                        } else {
                            completion("Non è stato possibile generare un outfit valido dopo diversi tentativi.")
                        }
                        return
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
    
    /// Verifica se l'outfit contiene più di una maglia o più di un pantalone (tranne eccezione camicia+maglia in casual/street)
    private static func isValidOutfit(items: [ClothingItem], ids: [String], targetStyle: String) -> Bool {
        // Seleziona solo gli oggetti inclusi nell'outfit
        let selected = items.filter { ids.contains($0.id.uuidString) }
        let macroByCat = Dictionary(grouping: selected, by: { $0.macrocategory })

        let maglie = macroByCat["Maglie"] ?? []
        let pantaloni = macroByCat["Pantaloni"] ?? []

        // Eccezione: camicia+maglia solo se stile casual/street
        if maglie.count > 1 {
            let hasMaglia = maglie.contains { $0.category.lowercased().contains("maglia") }
            let hasCamicia = maglie.contains { $0.category.lowercased().contains("camicia") }
            let isCasualOrStreet = targetStyle.lowercased().contains("casual") || targetStyle.lowercased().contains("street")
            if !(hasMaglia && hasCamicia && isCasualOrStreet) {
                return false
            }
        }
        // Più di un pantalone: sempre non valido
        if pantaloni.count > 1 {
            return false
        }
        return true
    }
}
