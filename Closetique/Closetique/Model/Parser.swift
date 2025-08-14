//
//  Parser.swift
//  Closetique
//
import Foundation


struct OutfitParser {
    /// Parsing che rispetta l'ordine degli id AI (ordine di presentazione nella risposta AI)
    static func parseOrdered(aiMessage: String, allItems: [ClothingItem]) -> (items: [ClothingItem], description: String) {
        let parts = aiMessage.components(separatedBy: "|")
        guard parts.count == 2 else { return ([], "") }
        let ids = parts[0]
            .split(separator: ";")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        let selected = ids.compactMap { id in
            allItems.first(where: { $0.id.uuidString == id })
        }
        let description = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
        return (selected, description)
    }

    /// Parsing che rispetta l'ordine di allItems (ad esempio per visualizzazione nell'armadio)
    static func parseByInventory(aiMessage: String, allItems: [ClothingItem]) -> (items: [ClothingItem], description: String) {
        let parts = aiMessage.components(separatedBy: "|")
        guard parts.count == 2 else { return ([], "") }
        let ids = parts[0]
            .split(separator: ";")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        let selected = allItems.filter { ids.contains($0.id.uuidString) }
        let description = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
        return (selected, description)
    }
}
