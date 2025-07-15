import SwiftUI

struct DetailView: View {
    @ObservedObject var item: ClothingItem
    @State var showDeleteAlert: Bool = false
    @Environment(\.dismiss) var dismiss
    var onDelete: (() -> Void)?
    
    // Carica tutti i capi dal database/local storage
    @State var allItems: [ClothingItem] = UserDefaultsManager.shared.loadItems()
    @State var generatedOutfit: String? = nil
    @State var showOutfitView: Bool = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        Rectangle()
                            .frame(width: 400, height: 500)
                            .foregroundColor(Color(red: 246/255, green: 232/255, blue: 234/255))
                            .cornerRadius(12)
                            .overlay(
                                ZStack(alignment: .bottomTrailing) {
                                    if let uiImage = imageFrom(item.imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 400, height: 450, alignment: .top)
                                            .cornerRadius(30)
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 400, height: 450)
                                            .cornerRadius(30)
                                            .overlay(Text("Nessuna immagine")
                                                .foregroundColor(.gray))
                                    }
                                    Button(action: {
                                        item.isFavorite.toggle()
                                    }) {
                                        Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                                            .foregroundColor(item.isFavorite ? .red : .gray)
                                            .padding(10)
                                            .background(Color.white.opacity(0.8))
                                            .clipShape(Circle())
                                            .shadow(radius: 2)
                                    }
                                    .padding([.trailing, .bottom], 16)
                                }
                            )
                    }
                    
                    Text(item.name)
                        .font(.custom("Poppins-Bold", size: 30))
                        .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                    
                    Text(item.macrocategory)
                        .font(.custom("Poppins-Regular", size: 20))
                        .foregroundColor(.secondary)
                    
                    Text(item.details ?? "")
                        .font(.custom("Poppins-Regular", size: 18))
                    
                    Spacer()
                }
                .padding(.bottom, 160)
                .navigationTitle("")
            }
            // Bottone "Genera Outfit"
            VStack {
                Spacer()
                Button(action: {
                    let fixedItem = item
                    let otherItems = allItems.filter { $0.id != item.id }
                    
                    // Chiamata API
                    LlamaGroqAPI.generateOutfitWithFixedItem(
                        fixedItem: fixedItem,
                        otherItems: otherItems
                    ) { result in
                        DispatchQueue.main.async {
                            generatedOutfit = result
                            showOutfitView = true
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 112/255, green: 41/255, blue: 99/255))
                            .frame(width: 130, height: 130)
                        Image("Button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 130, height: 130)
                    }
                }
                .accessibilityLabel("Genera Outfit")
                .padding(.bottom, 40)
                
                NavigationLink(
                    destination: OutfitGeneratedBySinglePieceView(
                        allItems: allItems,
                        aiMessage: generatedOutfit ?? "",
                        onRegenerate: {
                            let fixedItem = item
                            let otherItems = allItems.filter { $0.id != item.id }
                            LlamaGroqAPI.generateOutfitWithFixedItem(
                                fixedItem: fixedItem,
                                otherItems: otherItems
                            ) { result in
                                DispatchQueue.main.async {
                                    generatedOutfit = result
                                }
                            }
                        }
                    ),
                    isActive: $showOutfitView
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle(item.name)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("Elimina")
                        .foregroundColor(.red)
                }
            }
        })
        .alert("Sei sicuro di voler eliminare?", isPresented: $showDeleteAlert) {
            Button("Annulla", role: .cancel) { }
            Button("Elimina", role: .destructive) {
                UserDefaultsManager.shared.deleteItem(item)
                onDelete?()
                dismiss()
            }
        } message: {
            Text("Questa azione non può essere annullata.")
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
struct DetailView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var exampleItems = [
            ClothingItem(name: "Cappello", category: "Cappello", macrocategory: "Accessori", imageData: nil, details: nil, style: "Boh", isFavorite: false),
            ClothingItem(name: "Pino", category: "Pino", macrocategory: "Pantaloni", imageData: nil, details: nil, style: "NA", isFavorite: false),
            ClothingItem(name: "Maglia dal gusto discutibile", category: "Maglia dal gusto discutibile", macrocategory: "Maglie", imageData: nil, details: nil, style: "Casual", isFavorite: false),
            ClothingItem(name: "Maglia", category: "Maglia", macrocategory: "Maglie", imageData: nil, details: nil, style: "casual", isFavorite: false)
        ]
        var body: some View {
            DetailView(item: exampleItems[0], allItems: exampleItems)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
#endif
