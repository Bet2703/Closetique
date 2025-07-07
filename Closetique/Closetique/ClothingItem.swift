import Foundation
import Combine

class ClothingItem: Identifiable, ObservableObject, Codable, Equatable {
    var id = UUID()
    var name: String
    var category: String
    var imageData: String?
    var domColor: String?
    var detail: String?
    @Published var isFavorite: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, category, imageData, domColor, detail, isFavorite
    }

    init(name: String, category: String, imageData: String?, domColor: String? = nil, detail: String? = nil, isFavorite: Bool) {
        self.name = name
        self.category = category
        self.imageData = imageData
        self.domColor = domColor
        self.detail = detail
        self.isFavorite = isFavorite
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        imageData = try container.decodeIfPresent(String.self, forKey: .imageData)
        domColor = try container.decodeIfPresent(String.self, forKey: .domColor)
        detail = try container.decodeIfPresent(String.self, forKey: .detail)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encodeIfPresent(domColor, forKey: .domColor)
        try container.encodeIfPresent(detail, forKey: .detail)
        try container.encode(isFavorite, forKey: .isFavorite)
    }

    // MARK: - Equatable
    static func == (lhs: ClothingItem, rhs: ClothingItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.category == rhs.category &&
               lhs.imageData == rhs.imageData &&
               lhs.domColor == rhs.domColor &&
               lhs.detail == rhs.detail &&
               lhs.isFavorite == rhs.isFavorite
    }
}
