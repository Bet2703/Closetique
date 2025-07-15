import SwiftUI

struct WardrobeView: View {
    
    @Binding var items: [ClothingItem]
        
    
    @State private var selectedCategory: String? = nil
    @State private var showFavorites = false

    // Modalità selezione
    @State private var isSelecting = false
    @State private var selectedItems = Set<UUID>() // UUID degli item selezionati

    @State var showDeleteAlert: Bool = false
    
    let categories = ["Maglie", "Pantaloni", "Giacche", "Scarpe", "Accessori"]
        
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
                        
                        Button(action: {
                            showFavorites = true
                        }) {
                            Image(systemName: "heart")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                                .padding(10)
                                .background(Color(red: 246/255, green: 232/255, blue: 234/255))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 8)

                        // "Seleziona" o "Annulla"
                        Button(action: {
                            withAnimation {
                                isSelecting.toggle()
                                selectedItems.removeAll()
                            }
                        }) {
                            Image(systemName: isSelecting ? "xmark" : "checkmark.circle")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                                .padding(10)
                                .background(Color(red: 246/255, green: 232/255, blue: 234/255))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 8)

                        // "+" solo se NON stai selezionando
                        if !isSelecting {
                            NavigationLink(destination: CameraView(items: $items)) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                                    .padding(10)
                                    .background(Color(red: 246/255, green: 232/255, blue: 234/255))
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
                                    .font(.custom("Poppins-Regular", size: 18))
                                    .foregroundColor(selectedCategory == nil ? Color.white : Color.black)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == nil ? Color(red: 112/255, green: 41/255, blue: 99/255) : Color.gray.opacity(0.1))
                                    .cornerRadius(16)
                            }
                            ForEach(categories, id: \.self) { cat in
                                Button(action: { selectedCategory = cat }) {
                                    Text(cat)
                                        .font(.custom("Poppins-Regular", size: 18))
                                        .foregroundColor(selectedCategory == cat ? Color.white : Color.black)
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == cat ? Color(red: 112/255, green: 41/255, blue: 99/255) : Color.gray.opacity(0.1))
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
                                    UserDefaultsManager.shared.deleteItems(selectedItems)
                                    selectedItems.removeAll()
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
            .sheet(isPresented: $showFavorites) {
                NavigationStack {
                    FavoriteView(items: $items)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Chiudi") {
                                    showFavorites = false
                                }
                            }
                        }
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
    struct PreviewWrapper: View {
        @State var exampleItems = [
            ClothingItem(name: "Felpa", category: "Maglie", imageData: nil, details: "Stringa di dettagli per prova", isFavorite: false),
            ClothingItem(name: "Jeans", category: "Pantaloni", imageData: nil, details: "Stringa di dettagli per prova", isFavorite: true),
            ClothingItem(name: "T-shirt", category: "Maglie", imageData: nil, details: "Stringa di dettagli per prova", isFavorite: false),
            ClothingItem(name: "Cintura", category: "Accessori", imageData: nil, details: "Stringa di dettagli per prova", isFavorite: false),
            ClothingItem(name: "Sneakers", category: "Scarpe", imageData: nil, details: "Stringa di dettagli per prova", isFavorite: false)
        ]
        var body: some View {
            WardrobeView(items: $exampleItems)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
#endif
