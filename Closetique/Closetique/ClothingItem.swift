import Foundation
import Combine

class ClothingItem: Identifiable, ObservableObject, Codable, Equatable {
    var id: UUID
    var name: String
    var category: String
    var macrocategory: String
    var imagePath: String?
    var domColor: String?
    var details: String?
    var style: String
    @Published var isFavorite: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, category, macrocategory, imagePath, domColor, details, style, isFavorite
    }

    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        macrocategory: String,
        imagePath: String?,
        domColor: String? = nil,
        details: String? = nil,
        style: String = "",
        isFavorite: Bool
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.macrocategory = macrocategory
        self.imagePath = imagePath
        self.domColor = domColor
        self.details = details
        self.style = style
        self.isFavorite = isFavorite
        print("DEBUG: ClothingItem creato: name=\(name), category=\(category), macrocategory=\(macrocategory), imagePath nil? \(imagePath == nil), style=\(style), isFavorite=\(isFavorite)")
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        macrocategory = try container.decode(String.self, forKey: .macrocategory)
        imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
        domColor = try container.decodeIfPresent(String.self, forKey: .domColor)
        details = try container.decodeIfPresent(String.self, forKey: .details)
        style = try container.decodeIfPresent(String.self, forKey: .style) ?? ""
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        print("DEBUG: ClothingItem DECODIFICATO: name=\(name), imagePath=\(String(describing: imagePath))")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(macrocategory, forKey: .macrocategory)
        try container.encodeIfPresent(imagePath, forKey: .imagePath)
        try container.encodeIfPresent(domColor, forKey: .domColor)
        try container.encodeIfPresent(details, forKey: .details)
        try container.encode(style, forKey: .style)
        try container.encode(isFavorite, forKey: .isFavorite)
        print("DEBUG: ClothingItem CODIFICATO: name=\(name), imagePath=\(String(describing: imagePath))")
    }

    // MARK: - Equatable
    static func == (lhs: ClothingItem, rhs: ClothingItem) -> Bool {
        let eq = lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.category == rhs.category &&
            lhs.macrocategory == rhs.macrocategory &&
            lhs.imagePath == rhs.imagePath &&
            lhs.domColor == rhs.domColor &&
            lhs.details == rhs.details &&
            lhs.style == rhs.style &&
            lhs.isFavorite == rhs.isFavorite
        print("DEBUG: Confronto ClothingItem: \(lhs.name) == \(rhs.name)? \(eq)")
        return eq
    }
}
