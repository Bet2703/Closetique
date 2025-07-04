//
//  WardarobeView.swift
//  Closetique
//
//  Created by Studente on 02/07/25.
//
import SwiftUI

struct WardrobeView: View {
    @Binding var items: [ClothingItem]
    
    let categories = ["Maglie", "Pantaloni", "Giacche", "Scarpe", "Accessori"]
    @State private var selectedCategory: String? = nil

    var filteredItems: [ClothingItem] {
        if let selected = selectedCategory {
            return items.filter { $0.category == selected }
        } else {
            return items
        }
    }
    
    let gridColumns = [
        GridItem(.adaptive(minimum: 120, maximum: 200), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                // Titolo + pulsante "+"
                HStack {
                    Text("Armadio")
                        .font(.custom("Poppins-Bold", size: 40))
                        .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))

                    Spacer()

                    NavigationLink(destination: CameraView(items: $items)) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.purple)
                            .padding(10)
                            .background(Color.purple.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Categorie
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
                
                // Griglia immagini
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 18) {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: DetailView(item: item)) {
                                ZStack(alignment: .bottomTrailing) {
                                    Group {
                                        if let image = imageFrom(item.imageData) {
                                            GeometryReader { geo in
                                                Image(uiImage: image)
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
                                    
                                    Button(action: {
                                        if let idx = items.firstIndex(where: { $0.id == item.id }) {
                                            items[idx].isFavorite.toggle()
                                        }
                                    }) {
                                        Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                                            .foregroundColor(item.isFavorite ? .red : .gray)
                                            .padding(8)
                                            .background(Color.white.opacity(0.8))
                                            .clipShape(Circle())
                                            .shadow(radius: 2)
                                    }
                                    .padding(10)
                                }
                            }
                        }

                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // Utility per convertire imageData (base64 o filepath) in UIImage
    func imageFrom(_ imageData: String?) -> UIImage? {
        guard let imageData = imageData else { return nil }
        // Prova a decodificare Base64
        if let data = Data(base64Encoded: imageData),
           let image = UIImage(data: data) {
            return image
        }
        // Altrimenti prova a caricare da file path
        if let image = UIImage(contentsOfFile: imageData) {
            return image
        }
        // Altrimenti prova a caricare come URL
        if let url = URL(string: imageData),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
}

#if DEBUG
struct WardrobeView_Previews: PreviewProvider {
    static var previews: some View {
        // Esempio di dati di test
        let exampleItems = [
            ClothingItem(name: "Felpa", category: "Maglie", imageData: nil, isFavorite: false),
            ClothingItem(name: "Jeans", category: "Pantaloni", imageData: nil, isFavorite: true),
            ClothingItem(name: "T-shirt", category: "Maglie", imageData: nil, isFavorite: false),
            ClothingItem(name: "Cintura", category: "Accessori", imageData: nil, isFavorite: false),
            ClothingItem(name: "Sneakers", category: "Scarpe", imageData: nil, isFavorite: false)
        ]
        WardrobeView(items: .constant(exampleItems))
    }
}
#endif
