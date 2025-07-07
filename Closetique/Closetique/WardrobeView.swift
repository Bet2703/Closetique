import SwiftUI

struct WardrobeView: View {
    
    @State var items: [ClothingItem]
    let categories = ["Maglie", "Pantaloni", "Giacche", "Scarpe", "Accessori"]
    @State private var selectedCategory: String? = nil

    // Modalità selezione
    @State private var isSelecting = false
    @State private var selectedItems = Set<UUID>() // UUID degli item selezionati

    @State var showDeleteAlert: Bool = false
    
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
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    // Titolo + pulsanti
                    HStack {
                        Text("Armadio")
                            .font(.custom("Poppins-Bold", size: 40))
                            .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        Spacer()
                        
                        // "Seleziona" o "Annulla"
                        Button(action: {
                            withAnimation {
                                isSelecting.toggle()
                                selectedItems.removeAll()
                            }
                        }) {
                            Image(systemName: isSelecting ? "xmark" : "checkmark.circle")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.purple)
                                .padding(10)
                                .background(Color.purple.opacity(0.13))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 8)

                        // "+" solo se NON stai selezionando
                        if !isSelecting {
                            NavigationLink(destination: CameraView(items: $items)) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                                    .padding(10)
                                    .background(Color.purple.opacity(0.15))
                                    .clipShape(Circle())
                            }
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
                                if let index = items.firstIndex(where: { $0.id == item.id }) {
                                    if isSelecting {
                                        WardrobeSelectableItemCell(
                                            item: items[index],
                                            isSelected: selectedItems.contains(item.id),
                                            onTap: {
                                                if selectedItems.contains(item.id) {
                                                    selectedItems.remove(item.id)
                                                } else {
                                                    selectedItems.insert(item.id)
                                                }
                                            }
                                        )
                                        .animation(.easeInOut, value: selectedItems)
                                    } else {
                                        NavigationLink(
                                            destination: DetailView(item: items[index], onDelete: {
                                                items.remove(at: index)
                                            })
                                        ) {
                                            WardrobeItemCell(item: items[index])
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Armadio")
                .toolbar(.hidden, for: .navigationBar)

                // Barra inferiore solo in selezione
                if isSelecting {
                    VStack(spacing: 0) {
                        Divider()
                        HStack {
                            Spacer()
                            Button(action: {
                                // Elimina i selezionati
                                showDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .font(.title)
                                    .foregroundColor(selectedItems.isEmpty ? .gray : .red)
                                    .padding()
                                    .background(selectedItems.isEmpty ? Color.gray.opacity(0.15) : Color.red.opacity(0.15))
                                    .clipShape(Circle())
                            }.alert("Sei sicuro di voler eliminare?", isPresented: $showDeleteAlert) {
                                Button("Annulla", role: .cancel) { }
                                Button("Elimina", role: .destructive) {
                                    // Qui metti l'azione di eliminazione
                                    items.removeAll { selectedItems.contains($0.id) }
                                                                    selectedItems.removeAll()
                                    /*UserDefaultsManager.shared.deleteItem(selectedItems)*/
                                    isSelecting = false
                                    print("Elemento eliminato")
                                }
                            } message: {
                                Text("Questa azione non può essere annullata.")
                            }
                            
                            .disabled(selectedItems.isEmpty)
                            Spacer()
                        }
                        .frame(height: 60)
                        .background(.thinMaterial)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
        }
    }
}

// Cella normale
struct WardrobeItemCell: View {
    @ObservedObject var item: ClothingItem
    
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

// Cella selezionabile con overlay spunta
struct WardrobeSelectableItemCell: View {
    @ObservedObject var item: ClothingItem
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            WardrobeItemCell(item: item)
                .overlay(
                    isSelected ?
                        ZStack {
                            Color.black.opacity(0.25)
                                .cornerRadius(16)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 34))
                                .foregroundColor(.purple)
                        }
                        : nil
                )
                .onTapGesture {
                    onTap()
                }
        }
    }
}

#if DEBUG
struct WardrobeView_Previews: PreviewProvider {
    static var previews: some View {
        let exampleItems = [
            ClothingItem(name: "Felpa", category: "Maglie", imageData: nil, isFavorite: false),
            ClothingItem(name: "Jeans", category: "Pantaloni", imageData: nil, isFavorite: true),
            ClothingItem(name: "T-shirt", category: "Maglie", imageData: nil, isFavorite: false),
            ClothingItem(name: "Cintura", category: "Accessori", imageData: nil, isFavorite: false),
            ClothingItem(name: "Sneakers", category: "Scarpe", imageData: nil, isFavorite: false)
        ]
        WardrobeView(items: exampleItems)
    }
}
#endif
