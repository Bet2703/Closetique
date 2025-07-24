import Foundation

/// Rappresenta il risultato della classificazione di un capo (categoria, macro, stile, colore dominante, dettagli, colore HEX)
struct ClassificationResult {
    let category: String
    let macrocategory: String
    let style: String
    let domColor: String
    let details: String
    let hexColor: String
}
