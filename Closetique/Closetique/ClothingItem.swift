//
//  ClothingItem.swift
//  Closetique
//
//  Created by Studente on 04/07/25.
//

import Foundation

struct ClothingItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let category: String
    let imageData: String? // Base64 string, file path, or URL
    var isFavorite: Bool = false
}
