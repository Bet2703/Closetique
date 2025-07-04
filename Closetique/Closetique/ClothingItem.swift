import Foundation
import SwiftUI

class ClothingItem: Identifiable, ObservableObject {
    var id = UUID()
    var name: String
    var category: String
    var imageData: String?
    
    @Published var isFavorite: Bool
    
    init(name: String, category: String, imageData: String?, isFavorite: Bool) {
        self.name = name
        self.category = category
        self.imageData = imageData
        self.isFavorite = isFavorite
    }
}
