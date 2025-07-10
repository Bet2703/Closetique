import Foundation
import Combine

class ClothingItem: Identifiable, ObservableObject, Codable, Equatable {
    var id = UUID()
    var name: String
    var category: String
    var imageData: String?
    var domColor: String?
    var details: String?
    var style: String
    @Published var isFavorite: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, category, imageData, domColor, details, style, isFavorite
    }

    init(name: String, category: String, imageData: String?, domColor: String? = nil, details: String? = nil, style: String = "", isFavorite: Bool) {
        self.name = name
        self.category = category
        self.imageData = imageData
        self.domColor = domColor
        self.details = details
        self.style = style
        self.isFavorite = isFavorite
        print("DEBUG: ClothingItem creato: name=\(name), category=\(category), imageData nil? \(imageData == nil), style=\(style), isFavorite=\(isFavorite)")
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        imageData = try container.decodeIfPresent(String.self, forKey: .imageData)
        domColor = try container.decodeIfPresent(String.self, forKey: .domColor)
        details = try container.decodeIfPresent(String.self, forKey: .details)
        style = try container.decodeIfPresent(String.self, forKey: .style) ?? ""
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        print("DEBUG: ClothingItem DECODIFICATO: name=\(name), category=\(category), imageData nil? \(imageData == nil), style=\(style), isFavorite=\(isFavorite)")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encodeIfPresent(domColor, forKey: .domColor)
        try container.encodeIfPresent(details, forKey: .details)
        try container.encode(style, forKey: .style)
        try container.encode(isFavorite, forKey: .isFavorite)
        print("DEBUG: ClothingItem CODIFICATO: name=\(name), category=\(category), imageData nil? \(imageData == nil), style=\(style), isFavorite=\(isFavorite)")
    }

    // MARK: - Equatable
    static func == (lhs: ClothingItem, rhs: ClothingItem) -> Bool {
        let eq = lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.category == rhs.category &&
        lhs.imageData == rhs.imageData &&
        lhs.domColor == rhs.domColor &&
        lhs.details == rhs.details &&
        lhs.style == rhs.style &&
        lhs.isFavorite == rhs.isFavorite
        print("DEBUG: Confronto ClothingItem: \(lhs.name) == \(rhs.name)? \(eq)")
        return eq
    }
}
