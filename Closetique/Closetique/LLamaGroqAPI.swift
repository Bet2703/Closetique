import Foundation
import SwiftUI

class LlamaGroqAPI {
    static let apiKey = APIKeys.LLamaGroq
    static let endpoint = "https://api.groq.com/openai/v1/chat/completions"
    
    /// Genera una combinazione di capi, restituendo i loro id separati da `;` + descrizione separata da `|`
    static func generateOutfitCombo(
        from items: [ClothingItem],
        targetStyle: String,
        includePalette: Bool,
        completion: @escaping (String?) -> Void
    ) {
        let selectedSeason = UserDefaults.standard.string(forKey: "selectedSeason") ?? "N/A"
        let itemDescriptions = items.map {
            "id: \($0.id.uuidString), category: \($0.category), domColor: \($0.domColor ?? "N/A"), details: \($0.details ?? "N/A"), style: \($0.style), macro:\($0.macrocategory)"
        }.joined(separator: "\n")
        
        var userPrompt: String
        if includePalette {
            print("usa palette")
            userPrompt = """
            Questi sono i capi disponibili, ognuno ha id, category, domColor, details, style:
            \(itemDescriptions)
            Lo stile target per l'outfit è: "\(targetStyle)"
            La palette per l'armocromia è \(selectedSeason)
            IMPORTANTE:
            - Scegli una combinazione di N capi diversi (N >= 2, può essere superiore a 5/6).
            - NON accoppiare 2 maglie o 2 pantaloni nello stesso outfit (salvo eccezione: camicia sopra maglia SOLO se lo stile è casual o street).
            - Se includi due maglie o due pantaloni, il voto finale dell'outfit deve essere severamente penalizzato (max 2/10) e devi scrivere nella descrizione che l'outfit non è valido perché contiene due maglie o due pantaloni e devi essere molto severo.
            - Preferisci sempre macro-categorie differenti.
            - Preferisci abbinamenti coerenti con la palette dell'armocromia
            
            Rispondi SOLO in questo formato, senza nessun testo extra:
            <id1>;<id2>;<id3>;... | <descrizione creativa dell'outfit, con voto X/10 e motivazione. Se non hai rispettato le regole, spiega l'errore nella descrizione. Il voto deve essere estremamente severo. Inoltre parla del perché hai scelto questi abbinamenti anche in base alla palette.>

            Dove <idN> è ESATTAMENTE uno degli id forniti sopra (non scrivere mai nomi o categorie). NON inserire placeholder ("...") o testo aggiuntivo: solo id validi.

            Esempio di output (segui ESATTAMENTE questo formato, non aggiungere altro):
            A1B2C3;D4E5F6;G7H8I9 | Un outfit casual, 8/10. Maglia e jeans per un look rilassato.
            """
        } else {
            print("no palette")
            userPrompt = """
            Questi sono i capi disponibili, ognuno ha id, category, domColor, details, style:
            \(itemDescriptions)
            Lo stile target per l'outfit è: "\(targetStyle)"
            IMPORTANTE:
            - Scegli una combinazione di N capi diversi (N >= 2, può essere superiore a 5/6).
            - NON accoppiare 2 maglie o 2 pantaloni nello stesso outfit (salvo eccezione: camicia sopra maglia SOLO se lo stile è casual o street).
            - Se includi due maglie o due pantaloni, il voto finale dell'outfit deve essere severamente penalizzato (max 2/10) e devi scrivere nella descrizione che l'outfit non è valido perché contiene due maglie o due pantaloni e devi essere molto severo.
            - Preferisci sempre macro-categorie differenti.

            Rispondi SOLO in questo formato, senza nessun testo extra:
            <id1>;<id2>;<id3>;... | <descrizione creativa dell'outfit, con voto X/10 e motivazione. Se non hai rispettato le regole, spiega l'errore nella descrizione. Il voto deve essere estremamente severo.

            Dove <idN> è ESATTAMENTE uno degli id forniti sopra (non scrivere mai nomi o categorie). NON inserire placeholder ("...") o testo aggiuntivo: solo id validi.

            Esempio di output (segui ESATTAMENTE questo formato, non aggiungere altro):
            A1B2C3;D4E5F6;G7H8I9 | Un outfit casual, 8/10. Maglia e jeans per un look rilassato.
            """
        }

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

        guard let url = URL(string: endpoint) else {
            print("DEBUG: Endpoint URL non valida.")
            completion(nil)
            return
        }
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
                    let allParsedIds = content.components(separatedBy: "|").first?
                        .split(separator: ";")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? []
                    let ids = allParsedIds.filter { id in items.contains(where: { $0.id.uuidString == id }) }
                    let invalidIds = allParsedIds.filter { id in !items.contains(where: { $0.id.uuidString == id }) }
                    if !invalidIds.isEmpty {
                        print("DEBUG: Id non validi scartati: \(invalidIds)")
                    }
                    if !isValidOutfit(items: items, ids: ids) {
                        completion("Outfit non valido secondo le regole.")
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
    private static func isValidOutfit(items: [ClothingItem], ids: [String]) -> Bool {
        let selected = items.filter { ids.contains($0.id.uuidString) }
        let macroByCat = Dictionary(grouping: selected, by: { $0.macrocategory })

        let maglie = macroByCat["Maglie"] ?? []
        let pantaloni = macroByCat["Pantaloni"] ?? []

        // Eccezione: camicia+maglia sempre ok (non serve targetStyle)
        if maglie.count > 1 {
            let hasMaglia = maglie.contains { $0.category.lowercased().contains("maglia") }
            let hasCamicia = maglie.contains { $0.category.lowercased().contains("camicia") }
            if !(hasMaglia && hasCamicia) {
                return false
            }
        }
        if pantaloni.count > 1 {
            return false
        }
        return true
    }

    /// Genera una combinazione di capi includendo SEMPRE il capo indicato, senza stile target
    static func generateOutfitWithFixedItem(
        fixedItem: ClothingItem,
        otherItems: [ClothingItem],
        completion: @escaping (String?) -> Void
    ) {
        let allItems = [fixedItem] + otherItems
        let itemDescriptions = allItems.map {
            """
            id: \($0.id.uuidString), category: \($0.category), domColor: \($0.domColor ?? "N/A"), details: \($0.details ?? "N/A"), style: \($0.style), macro:\($0.macrocategory)
            """
        }.joined(separator: "\n")
        
        print("DEBUG: CAPIS disponibili per la AI:")
        for item in allItems {
            print("DEBUG: id=\(item.id.uuidString), name=\(item.name)")
        }

        let userPrompt =
        """
        Questi sono i capi disponibili, ognuno ha id, category, domColor, details, style:
        \(itemDescriptions)

        IMPORTANTE:
        - L'outfit generato deve includere SEMPRE il capo con id \(fixedItem.id.uuidString).
        - Scegli una combinazione di N capi diversi (N >= 2, può essere superiore a 5/6).
        - NON accoppiare 2 maglie o 2 pantaloni nello stesso outfit (salvo eccezione: camicia sopra maglia).
        - Se includi due maglie o due pantaloni, il voto finale dell'outfit deve essere severamente penalizzato (max 2/10) e devi scrivere nella descrizione che l'outfit non è valido perché contiene due maglie o due pantaloni e devi essere molto severo.
        - Preferisci sempre macro-categorie differenti.

        Rispondi SOLO in questo formato, senza nessun testo extra:
        <id1>;<id2>;<id3>;... | <descrizione creativa dell'outfit, con voto X/10 e motivazione. Se non hai rispettato le regole, spiega l'errore nella descrizione. Il voto deve essere severo.

        Dove <idN> è ESATTAMENTE uno degli id forniti sopra (non scrivere mai nomi o categorie). NON inserire placeholder ("...") o testo aggiuntivo: solo id validi.

        Esempio di output (segui ESATTAMENTE questo formato, non aggiungere altro):
        A1B2C3;D4E5F6;G7H8I9 | Un outfit casual, 8/10. Maglia e jeans per un look rilassato.
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

        guard let url = URL(string: endpoint) else {
            print("DEBUG: Endpoint URL non valida.")
            completion(nil)
            return
        }
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

        func isValidOutfit(items: [ClothingItem], ids: [String]) -> Bool {
            let selected = items.filter { ids.contains($0.id.uuidString) }
            let macroByCat = Dictionary(grouping: selected, by: { $0.macrocategory })
            let maglie = macroByCat["Maglie"] ?? []
            let pantaloni = macroByCat["Pantaloni"] ?? []
            if maglie.count > 1 {
                let hasMaglia = maglie.contains { $0.category.lowercased().contains("maglia") }
                let hasCamicia = maglie.contains { $0.category.lowercased().contains("camicia") }
                if !(hasMaglia && hasCamicia) {
                    return false
                }
            }
            if pantaloni.count > 1 {
                return false
            }
            return true
        }

        func tryRequest(attempt: Int = 1) {
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
                        print("DEBUG: OUTPUT Llama: \(content)")
                        let allParsedIds = content.components(separatedBy: "|").first?
                            .split(separator: ";")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? []
                        let ids = allParsedIds.filter { id in allItems.contains(where: { $0.id.uuidString == id }) }
                        let invalidIds = allParsedIds.filter { id in !allItems.contains(where: { $0.id.uuidString == id }) }
                        print("DEBUG: Id generati dalla AI: \(allParsedIds)")
                        print("DEBUG: Id validi trovati: \(ids)")
                        print("DEBUG: Id non validi scartati: \(invalidIds)")
                        for id in allParsedIds {
                            if let found = allItems.first(where: { $0.id.uuidString == id }) {
                                print("DEBUG: MATCH: \(id) -> \(found.name)")
                            } else {
                                print("DEBUG: NO MATCH: \(id)")
                            }
                        }
                        // Deve includere sempre il capo fisso
                        if !ids.contains(fixedItem.id.uuidString) {
                            print("DEBUG: Outfit non include il capo richiesto, rigenero... Tentativo \(attempt)")
                            if attempt < 8 {
                                let delay = pow(2.0, Double(attempt))
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                    tryRequest(attempt: attempt + 1)
                                }
                            } else {
                                completion("Non è stato possibile generare un outfit valido dopo diversi tentativi.")
                            }
                            return
                        }
                        // Validità outfit (regole maglie/pantaloni)
                        if !isValidOutfit(items: allItems, ids: ids) {
                            print("DEBUG: Outfit non valido (2 maglie/pantaloni), rigenero... Tentativo \(attempt)")
                            if attempt < 16 {
                                let delay = pow(2.0, Double(attempt))
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                    tryRequest(attempt: attempt + 1)
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

        tryRequest()
    }
}
