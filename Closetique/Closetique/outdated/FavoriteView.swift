/*import SwiftUI

struct FavoriteView: View {
    @Binding var items: [ClothingItem]
    
    // Mostra solo i preferiti
    var filteredItems: [ClothingItem] {
        items.filter { $0.isFavorite }
    }
    
    let gridColumns = [
        GridItem(.adaptive(minimum: 120, maximum: 200), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                // Titolo
                HStack {
                    Text("Preferiti")
                        .font(.custom("Poppins-Bold", size: 40))
                        .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Griglia immagini
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 18) {
                        ForEach(filteredItems) { item in
                            if let idx = items.firstIndex(where: { $0.id == item.id }) {
                                NavigationLink(
                                    destination: DetailView(item: items[idx], onDelete: {
                                        items.remove(at: idx)
                                    })
                                ) {
                                    FavoriteItemCell(item: items[idx]) {
                                        /*if !items[idx].isFavorite {
                                            items.remove(at: idx)
                                        }*/
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Preferiti")
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct FavoriteItemCell: View {
    @ObservedObject var item: ClothingItem
    var onFavoriteToggle: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let image = imageFromPath(item.imagePath) {
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
                item.isFavorite.toggle()
                onFavoriteToggle()
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
    func imageFromPath(_ path: String?) -> UIImage? {
        guard let path = path else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

/*
#if DEBUG
struct FavoriteView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var exampleItems = [
            ClothingItem(name: "Felpa", category: "Felpa", macrocategory: "Maglie", imagePath: nil, style: "Casual", isFavorite: false),
            ClothingItem(name: "Jeans", category: "Jeans", macrocategory: "Pantaloni", imagePath: nil, style: "Street", isFavorite: true),
            ClothingItem(name: "T-shirt", category: "T-shirt", macrocategory: "Maglie", imagePath: nil, style: "Sport", isFavorite: true),
            ClothingItem(name: "Cintura", category: "Cintura", macrocategory: "Accessori", imagePath: nil, style: "Classico", isFavorite: false),
            ClothingItem(name: "Sneakers", category: "Sneakers", macrocategory: "Scarpe", imagePath: nil, style: "Urban", isFavorite: false)
        ]
        var body: some View {
            FavoriteView(items: $exampleItems)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
#endif
*/
*/
