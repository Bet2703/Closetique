import Foundation
import Combine

class MatchOutfit: Identifiable, ObservableObject, Codable, Equatable {
    var id: UUID
    var items: [ClothingItem]
    var description: String?
    var dateCreated: Date

    enum CodingKeys: String, CodingKey {
        case id, items, description, dateCreated
    }

    init(items: [ClothingItem], description: String? = nil, dateCreated: Date = Date()) {
        self.id = UUID()
        self.items = items
        self.description = description
        self.dateCreated = dateCreated
        print("DEBUG: MatchOutfit creato con \(items.count) items, description: \(description ?? "nessuna")")
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        items = try container.decode([ClothingItem].self, forKey: .items)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        print("DEBUG: MatchOutfit DECODIFICATO con \(items.count) items, description: \(description ?? "nessuna")")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(items, forKey: .items)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(dateCreated, forKey: .dateCreated)
        print("DEBUG: MatchOutfit CODIFICATO con \(items.count) items, description: \(description ?? "nessuna")")
    }

    // MARK: - Equatable
    static func == (lhs: MatchOutfit, rhs: MatchOutfit) -> Bool {
        let eq = lhs.id == rhs.id &&
        lhs.items == rhs.items &&
        lhs.description == rhs.description &&
        lhs.dateCreated == rhs.dateCreated
        print("DEBUG: Confronto MatchOutfit: ids uguali? \(lhs.id == rhs.id), items uguali? \(lhs.items == rhs.items)")
        return eq
    }
}
