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

    let availableCategories: [String] = ["Maglie", "Pantaloni", "Giubbini", "Gonne", "Abiti", "Scarpe", "Accessori", "Extra"]

    // Stati per editing per ogni campo
    @State private var isEditingNome = false
    @State private var isEditingCategoriaMacro = false
    @State private var isEditingStile = false
    @State private var isEditingColore = false
    @State private var isEditingDettagli = false
    
    @State private var editableNome = ""
    @State private var editableCategoria = ""
    @State private var editableMacrocategory = ""
    @State private var editableStile = ""
    @State private var editableDomColor = ""
    @State private var editableDettagli = ""

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Immagine e cuore
                    ZStack {
                        Rectangle()
                            .frame(width: 400, height: 480)
                            .foregroundColor(Color(red: 246/255, green: 232/255, blue: 234/255))
                            .cornerRadius(12)
                            .overlay(
                                ZStack(alignment: .bottomTrailing) {
                                    if let uiImage = imageFrom(item.imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 400, height: 420, alignment: .top)
                                            .cornerRadius(30)
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 400, height: 420)
                                            .cornerRadius(30)
                                            .overlay(Text("Nessuna immagine")
                                                .foregroundColor(.gray))
                                    }
                                    Button(action: {
                                        item.isFavorite.toggle()
                                        UserDefaultsManager.shared.updateItem(item)
                                        allItems = UserDefaultsManager.shared.loadItems()
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

                    // NOME con pencil/check
                    HStack {
                        if isEditingNome {
                            TextField("Nome", text: $editableNome)
                                .font(.custom("Poppins-Bold", size: 40))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                                .frame(maxWidth: 250)
                            Button(action: {
                                isEditingNome = false
                                item.name = editableNome
                                UserDefaultsManager.shared.updateItem(item)
                                allItems = UserDefaultsManager.shared.loadItems()
                            }) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                            }
                        } else {
                            Text(item.name)
                                .font(.custom("Poppins-Bold", size: 40))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                            Button(action: {
                                isEditingNome = true
                                editableNome = item.name
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                            }
                        }
                    }

                    // Categoria/Macrocategoria con pencil/check
                    HStack(alignment: .center) {
                        if isEditingCategoriaMacro {
                            TextField("Categoria", text: $editableCategoria)
                                .font(.custom("Poppins-Regular", size: 22))
                                .frame(maxWidth: 110)
                            Text("/")
                                .font(.custom("Poppins-Regular", size: 22))
                            Menu {
                                ForEach(availableCategories, id: \.self) { cat in
                                    Button(action: { editableMacrocategory = cat }) {
                                        Text(cat)
                                    }
                                }
                            } label: {
                                Text(editableMacrocategory)
                                    .font(.custom("Poppins-Regular", size: 22))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemGray6))
                                    )
                            }
                            .frame(maxWidth: 110)
                            Button(action: {
                                isEditingCategoriaMacro = false
                                item.category = editableCategoria
                                item.macrocategory = editableMacrocategory
                                UserDefaultsManager.shared.updateItem(item)
                                allItems = UserDefaultsManager.shared.loadItems()
                            }) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                            }
                        } else {
                            Text("\(item.category)/\(item.macrocategory)")
                                .font(.custom("Poppins-Regular", size: 22))
                            Button(action: {
                                isEditingCategoriaMacro = true
                                editableCategoria = item.category
                                editableMacrocategory = item.macrocategory
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                            }
                        }
                    }
                    .padding(.top, 1)

                    // STILE & COLORE con pencil/check
                    HStack(alignment: .center) {
                        Text("Stile: ")
                            .font(.custom("Poppins-SemiBold", size: 20))
                            .padding(.leading, 20)
                        if isEditingStile {
                            TextField("Stile", text: $editableStile)
                                .font(.custom("Poppins-Regular", size: 20))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 235/255, green: 235/255, blue: 235/255))
                                )
                            Button(action: {
                                isEditingStile = false
                                item.style = editableStile
                                UserDefaultsManager.shared.updateItem(item)
                                allItems = UserDefaultsManager.shared.loadItems()
                            }) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                            }
                        } else {
                            Text(item.style)
                                .font(.custom("Poppins-Regular", size: 20))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 235/255, green: 235/255, blue: 235/255))
                                )
                            Button(action: {
                                isEditingStile = true
                                editableStile = item.style
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                            }
                        }
                        Spacer()
                        Text("Colore: ")
                            .font(.custom("Poppins-SemiBold", size: 20))
                        Circle()
                            .stroke(Color.gray)
                            .fill(.green)
                            .frame(width: 28)
                        if isEditingColore {
                            TextField("Colore", text: $editableDomColor)
                                .font(.custom("Poppins-Regular", size: 20))
                                .padding(.trailing, 10)
                                .frame(width: 70)
                            Button(action: {
                                isEditingColore = false
                                item.domColor = editableDomColor
                                UserDefaultsManager.shared.updateItem(item)
                                allItems = UserDefaultsManager.shared.loadItems()
                            }) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                            }
                        } else {
                            Text(item.domColor ?? "")
                                .font(.custom("Poppins-Regular", size: 20))
                                .padding(.trailing, 10)
                                .frame(width: 70, alignment: .leading)
                            Button(action: {
                                isEditingColore = true
                                editableDomColor = item.domColor ?? ""
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                            }
                        }
                    }

                    // DETTAGLI con pencil/check
                    HStack(alignment: .top) {
                        if isEditingDettagli {
                            TextField("Dettagli", text: $editableDettagli, axis: .vertical)
                                .font(.custom("Poppins-Regular", size: 20))
                                .padding(.leading, 10)
                                .padding(.trailing, 10)
                                .multilineTextAlignment(.leading)
                                .lineLimit(3...8)
                            Button(action: {
                                isEditingDettagli = false
                                item.details = editableDettagli
                                UserDefaultsManager.shared.updateItem(item)
                                allItems = UserDefaultsManager.shared.loadItems()
                            }) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                            }
                        } else {
                            Text(item.details ?? "")
                                .font(.custom("Poppins-Regular", size: 20))
                                .padding(.leading, 10)
                                .padding(.trailing, 10)
                            Button(action: {
                                isEditingDettagli = true
                                editableDettagli = item.details ?? ""
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.bottom, 160)
                .navigationTitle("")
                .onAppear {
                    editableNome = item.name
                    editableCategoria = item.category
                    editableMacrocategory = item.macrocategory
                    editableStile = item.style
                    editableDomColor = item.domColor ?? ""
                    editableDettagli = item.details ?? ""
                }
            }

            // Bottone "Genera Outfit"
            VStack {
                Spacer()
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 160)
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
                    .padding(.bottom, 10)
                }

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
            ClothingItem(name: "Pinocchietto", category: "Pantaloncino", macrocategory: "Pantaloni", imageData: nil, domColor: "Verde", details: "Un pinocchietto di lana corto lungo bianco verde rosso giallo di cotone ah no di lana", style: "Casual", isFavorite: false),
            ClothingItem(name: "Cappello", category: "Cappello", macrocategory: "Accessori", imageData: nil, details: nil, style: "Boh", isFavorite: false),
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
