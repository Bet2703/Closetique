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
            userPrompt = """
            Questi sono i capi disponibili, ognuno ha id, category, domColor, details, style:
            \(itemDescriptions)
            Lo stile target per l'outfit è: "\(targetStyle)"
            La palette per l'armocromia è \(selectedSeason).

            ISTRUZIONI IMPORTANTI (SEGUILE ALLA LETTERA):

            1. Scegli una combinazione di N capi diversi (N >= 2, può essere superiore a 5/6).
            2. NON accoppiare mai 2 maglie o 2 pantaloni nello stesso outfit.
               - Unica eccezione: puoi mettere una camicia sopra una maglia SOLO se lo stile è casual o street.
            3. Se scegli due maglie o due pantaloni, il voto dell'outfit deve essere max 2/10 e la descrizione deve spiegare l'errore e penalizzare severamente la scelta.
            4. Preferisci sempre macro-categorie differenti.
            5. Preferisci abbinamenti coerenti con la palette dell'armocromia.

            FORMATO DI RISPOSTA OBBLIGATORIO:
            Esclusivamente questo formato, senza nessun testo extra:
            <id1>;<id2>;<id3>;... | <descrizione creativa dell'outfit, con voto X/10 e motivazione. Se non hai rispettato le regole, spiega l'errore nella descrizione. Il voto deve essere estremamente severo. Inoltre parla del perché hai scelto questi abbinamenti anche in base alla palette.>

            ATTENZIONE:
            - Ogni <idN> deve essere ESATTAMENTE uno degli id forniti sopra (mai nomi o categorie).
            - NON inserire placeholder ("...") o testo aggiuntivo: solo id validi e la descrizione richiesta.
            - Non scrivere mai testo prima o dopo la risposta, né spiegazioni aggiuntive.

            Esempio (segui ESATTAMENTE questo schema):
            A1B2C3;D4E5F6;G7H8I9 | Un outfit casual, 8/10. Maglia e jeans per un look rilassato, colori coerenti con la palette primavera.
            """
        } else {
            userPrompt = """
            Questi sono i capi disponibili, ognuno ha id, category, domColor, details, style:
            \(itemDescriptions)
            Lo stile target per l'outfit è: "\(targetStyle)"

            ISTRUZIONI IMPORTANTI (SEGUILE ALLA LETTERA):

            1. Scegli una combinazione di N capi diversi (N >= 2, può essere superiore a 5/6).
            2. NON accoppiare mai 2 maglie o 2 pantaloni nello stesso outfit.
               - Unica eccezione: puoi mettere una camicia sopra una maglia SOLO se lo stile è casual o street.
            3. Se scegli due maglie o due pantaloni, il voto dell'outfit deve essere max 2/10 e la descrizione deve spiegare l'errore e penalizzare severamente la scelta.
            4. Preferisci sempre macro-categorie differenti.

            FORMATO DI RISPOSTA OBBLIGATORIO:
            Esclusivamente questo formato, senza nessun testo extra:
            <id1>;<id2>;<id3>;... | <descrizione creativa dell'outfit, con voto X/10 e motivazione. Se non hai rispettato le regole, spiega l'errore nella descrizione. Il voto deve essere estremamente severo.

            ATTENZIONE:
            - Ogni <idN> deve essere ESATTAMENTE uno degli id forniti sopra (mai nomi o categorie).
            - NON inserire placeholder ("...") o testo aggiuntivo: solo id validi e la descrizione richiesta.
            - Non scrivere mai testo prima o dopo la risposta, né spiegazioni aggiuntive.

            Esempio (segui ESATTAMENTE questo schema):
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
                    if !isValidOutfit(items: items, ids: ids, userPrompt: userPrompt) {
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
    private static func isValidOutfit(items: [ClothingItem], ids: [String], userPrompt: String? = nil) -> Bool {
        let selected = items.filter { ids.contains($0.id.uuidString) }
        let macroByCat = Dictionary(grouping: selected, by: { $0.macrocategory })

        let maglie = macroByCat["Maglie"] ?? []
        let pantaloni = macroByCat["Pantaloni"] ?? []

        // Ricava stile dal prompt se disponibile
        let style = userPrompt?.components(separatedBy: "Lo stile target per l'outfit è: \"").last?.components(separatedBy: "\"").first?.lowercased() ?? ""

        if maglie.count > 1 {
            let hasMaglia = maglie.contains { $0.category.lowercased().contains("maglia") }
            let hasCamicia = maglie.contains { $0.category.lowercased().contains("camicia") }
            // Eccezione: camicia sopra maglia SOLO se stile casual o street
            if !(hasMaglia && hasCamicia && (style.contains("casual") || style.contains("street"))) {
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
        
        let userPrompt =
        """
        Questi sono i capi disponibili, ognuno ha id, category, domColor, details, style:
        \(itemDescriptions)

        ISTRUZIONI IMPORTANTI (SEGUILE ALLA LETTERA):

        - L'outfit generato deve includere SEMPRE il capo con id \(fixedItem.id.uuidString).
        - Scegli una combinazione di N capi diversi (N >= 2, può essere superiore a 5/6).
        - NON accoppiare 2 maglie o 2 pantaloni nello stesso outfit (salvo eccezione: camicia sopra maglia SOLO se lo stile è casual o street).
        - Se includi due maglie o due pantaloni, il voto finale dell'outfit deve essere severamente penalizzato (max 2/10) e devi scrivere nella descrizione che l'outfit non è valido perché contiene due maglie o due pantaloni e devi essere molto severo.
        - Preferisci sempre macro-categorie differenti.

        FORMATO DI RISPOSTA OBBLIGATORIO:
        Esclusivamente questo formato, senza nessun testo extra:
        <id1>;<id2>;<id3>;... | <descrizione creativa dell'outfit, con voto X/10 e motivazione. Se non hai rispettato le regole, spiega l'errore nella descrizione. Il voto deve essere estremamente severo.

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

        func isValidOutfit(items: [ClothingItem], ids: [String], userPrompt: String? = nil) -> Bool {
            let selected = items.filter { ids.contains($0.id.uuidString) }
            let macroByCat = Dictionary(grouping: selected, by: { $0.macrocategory })
            let maglie = macroByCat["Maglie"] ?? []
            let pantaloni = macroByCat["Pantaloni"] ?? []
            // Ricava stile dal prompt se disponibile
            let style = userPrompt?.components(separatedBy: "Lo stile target per l'outfit è: \"").last?.components(separatedBy: "\"").first?.lowercased() ?? ""
            if maglie.count > 1 {
                let hasMaglia = maglie.contains { $0.category.lowercased().contains("maglia") }
                let hasCamicia = maglie.contains { $0.category.lowercased().contains("camicia") }
                // Eccezione: camicia sopra maglia SOLO se stile casual o street
                if !(hasMaglia && hasCamicia && (style.contains("casual") || style.contains("street"))) {
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
                        let allParsedIds = content.components(separatedBy: "|").first?
                            .split(separator: ";")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? []
                        let ids = allParsedIds.filter { id in allItems.contains(where: { $0.id.uuidString == id }) }
                        let invalidIds = allParsedIds.filter { id in !allItems.contains(where: { $0.id.uuidString == id }) }
                        // Deve includere sempre il capo fisso
                        if !ids.contains(fixedItem.id.uuidString) {
                            print("DEBUG: Outfit non include il capo richiesto, rigenero... Tentativo \(attempt)")
                            if attempt < 20 {
                                let delay = pow(1.5, Double(attempt))
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                    tryRequest(attempt: attempt + 1)
                                }
                            } else {
                                completion("Non è stato possibile generare un outfit valido dopo diversi tentativi.")
                            }
                            return
                        }
                        // Validità outfit (regole maglie/pantaloni)
                        if !isValidOutfit(items: allItems, ids: ids, userPrompt: userPrompt) {
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
