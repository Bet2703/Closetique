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
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        items = try container.decode([ClothingItem].self, forKey: .items)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(items, forKey: .items)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(dateCreated, forKey: .dateCreated)
    }

    // MARK: - Equatable
    static func == (lhs: MatchOutfit, rhs: MatchOutfit) -> Bool {
        return lhs.id == rhs.id &&
               lhs.items == rhs.items &&
               lhs.description == rhs.description &&
               lhs.dateCreated == rhs.dateCreated
    }
    func generateOutfitWithAllItems(completion: @escaping (MatchOutfit?) -> Void) {
        let clothingItems = UserDefaultsManager.shared.loadItems()
        guard !clothingItems.isEmpty else {
            completion(nil)
            return
        }
        LlamaGroqAPI.generateOutfitDescription(from: clothingItems) { description in
            if let descr = description {
                let newOutfit = MatchOutfit(items: clothingItems, description: descr)
                completion(newOutfit)
            } else {
                completion(nil)
            }
        }
    }
}
