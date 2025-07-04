//
//  FavoriteView.swift
//  Closetique
//
//  Created by Studente on 04/07/25.
//
import SwiftUI

struct FavoriteView: View {
    @Binding var items: [ClothingItem]
    
    var favoriteItems: [ClothingItem] {
        items.filter { $0.isFavorite }
    }
    
    let gridColumns = [
        GridItem(.adaptive(minimum: 120, maximum: 200), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Preferiti")
                    .font(.custom("Poppins-Bold", size: 40))
                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                    .padding(.horizontal)
                    .padding(.top)
                
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 18) {
                        ForEach(favoriteItems) { item in
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
struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        // Esempio di dati di test
        let exampleItems = [
            ClothingItem(name: "Felpa", category: "Maglie", imageData: nil, isFavorite: false),
            ClothingItem(name: "Jeans", category: "Pantaloni", imageData: nil, isFavorite: true),
            ClothingItem(name: "T-shirt", category: "Maglie", imageData: nil, isFavorite: true),
            ClothingItem(name: "Cintura", category: "Accessori", imageData: nil, isFavorite: false),
            ClothingItem(name: "Sneakers", category: "Scarpe", imageData: nil, isFavorite: false)
        ]
        FavoriteView(items: .constant(exampleItems))
    }
}
#endif
