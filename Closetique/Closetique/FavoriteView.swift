import SwiftUI

struct FavoriteView: View {
    @State var items: [ClothingItem] 
    
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
                            NavigationLink(
                                destination: DetailView(item: item, onDelete: {
                                    if let idx = items.firstIndex(where: { $0.id == item.id }) {
                                        items.remove(at: idx)
                                    }
                                })
                            ) {
                                FavoriteItemCell(item: item) {
                                    
                                    if !item.isFavorite, let idx = items.firstIndex(where: { $0.id == item.id }) {
                                        items.remove(at: idx)
                                        
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
    func imageFrom(_ imageData: String?) -> UIImage? {
        guard let imageData = imageData else { return nil }
        if let data = Data(base64Encoded: imageData),
           let image = UIImage(data: data) {
            return image
        }
        if let image = UIImage(contentsOfFile: imageData) {
            return image
        }
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
    struct PreviewWrapper: View {
        @State var exampleItems = [
            ClothingItem(name: "Felpa", category: "Maglie", imageData: nil, isFavorite: false),
            ClothingItem(name: "Jeans", category: "Pantaloni", imageData: nil, isFavorite: true),
            ClothingItem(name: "T-shirt", category: "Maglie", imageData: nil, isFavorite: true),
            ClothingItem(name: "Cintura", category: "Accessori", imageData: nil, isFavorite: false),
            ClothingItem(name: "Sneakers", category: "Scarpe", imageData: nil, isFavorite: false)
        ]
        var body: some View {
            FavoriteView(items: exampleItems)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
#endif
