//
//  WardarobeView.swift
//  Closetique
//
//  Created by Studente on 02/07/25.
//

import SwiftUI

struct ClothingItem: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let imageData: Data?
}

struct WardrobeView: View {
    @State private var selectedCategory: String? = nil
    @State private var categories: [String] = ["Maglie", "Pantaloni", "Giacche", "Scarpe", "Accessori"]
    @State private var items: [ClothingItem] = [
        // ESEMPI: Sostituisci con i tuoi dati reali
        ClothingItem(name: "Felpa", category: "Maglie", imageData: nil),
        ClothingItem(name: "Jeans", category: "Pantaloni", imageData: nil),
        ClothingItem(name: "T-shirt", category: "Maglie", imageData: nil),
        ClothingItem(name: "Cintura", category: "Accessori", imageData: nil),
        ClothingItem(name: "Sneakers", category: "Scarpe", imageData: nil)
    ]
    
    var filteredItems: [ClothingItem] {
        if let selected = selectedCategory {
            return items.filter { $0.category == selected }
        } else {
            return items
        }
    }
    
    // Layout a 2 colonne, ma le celle si adattano all'immagine
    let gridColumns = [
        GridItem(.adaptive(minimum: 120, maximum: 200), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            // Barra filtri categorie
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button(action: { selectedCategory = nil }) {
                        Text("Tutti")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(selectedCategory == nil ? Color.purple.opacity(0.2) : Color.gray.opacity(0.1))
                            .foregroundColor(.primary)
                            .cornerRadius(16)
                    }
                    ForEach(categories, id: \.self) { cat in
                        Button(action: { selectedCategory = cat }) {
                            Text(cat)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(selectedCategory == cat ? Color.purple.opacity(0.2) : Color.gray.opacity(0.1))
                                .foregroundColor(.primary)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            
            // Griglia dinamica di sole immagini
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 18) {
                    ForEach(filteredItems) { item in
                        Group {
                            if let data = item.imageData, let uiImage = UIImage(data: data) {
                                GeometryReader { geo in
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geo.size.width, height: geo.size.width)
                                        .clipped()
                                        .cornerRadius(12)
                                }
                                .aspectRatio(1, contentMode: .fit)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .aspectRatio(1, contentMode: .fit)
                                    .cornerRadius(12)
                                    .overlay(Text("No Image").font(.caption))
                            }
                        }
                        .padding(4)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Il mio armadio")
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    WardrobeView()
}
