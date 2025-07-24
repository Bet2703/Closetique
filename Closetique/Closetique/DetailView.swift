//
//  DetailView.swift
//  Closetique
//

import SwiftUI

/// Gestisce la visualizzazione della pagina dei dettagli del singolo capo mostrando immagine, toggle dei preferiti, nome, categoria, macrocategoria, stile, colore e una breve descrizione
struct DetailView: View {
    
    @ObservedObject var item: ClothingItem // Mantiene riferimento al capo,riflettendo tutti i cambiamenti
    @Binding var selectedTab: Int // Tiene traccia dello stato della TabBar
    @State var showDeleteAlert: Bool = false // Abilita la visualizzazione dell'alert
    @Environment(\.dismiss) var dismiss // Permette di tornare alla view precedente
    var onDelete: (() -> Void)?
    
    @State var allItems: [ClothingItem] = UserDefaultsManager.shared.loadItems() // Carica tutti i capi dal database/local storage
    
    let availableCategories: [String] = ["Maglie", "Camicie", "Pantaloni", "Gonne", "Abiti", "Giacca", "Giubbino", "Cappotto", "Scarpe", "Accessori", "Extra"]
    
    // Per la generazione dell'outfit a partire dal capo visualizzato
    @State var generatedOutfit: String? = nil // Gestisce la generazione dell'outfit a partire dal capo mostrato
    @State var showOutfitView: Bool = false // Gestisce la visualizzazione dell'outfit generato
    @State var outfitGenerationError: String? = nil // Gestisce gli errori di generazione dell'outfit

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
                                    if let uiImage = imageFromPath(item.imagePath) {
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
                    
                    //STILE con pencil/check
                    HStack(alignment: .center) {
                        Text("Stile: ")
                            .font(.custom("Poppins-SemiBold", size: 20))
                            .padding(.leading, 10)
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
                        
                    }
                    
                    //COLORE con pencil/check
                    HStack(alignment: .center) {
                        Text("Colore: ")
                            .font(.custom("Poppins-SemiBold", size: 20))
                        Circle()
                            .stroke(Color.gray)
                            .fill(Color(Hex: item.hexColor))
                            .frame(width: 28)
                        Text(item.domColor ?? "")
                            .font(.custom("Poppins-Regular", size: 20))
                            .padding(.trailing, 10)
                            .multilineTextAlignment(.leading)
                            .frame(width: 150, alignment: .leading)
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
                                if let output = result {
                                    if output.starts(with: "Outfit non valido") || output.starts(with: "Non è stato possibile") {
                                        self.outfitGenerationError = output
                                        self.generatedOutfit = ""
                                        self.showOutfitView = true
                                    } else {
                                        self.generatedOutfit = output
                                        self.outfitGenerationError = nil
                                        self.showOutfitView = true
                                    }
                                } else {
                                    self.outfitGenerationError = "Errore nella generazione dell'outfit."
                                    self.generatedOutfit = ""
                                    self.showOutfitView = true
                                }
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
                        selectedTab: $selectedTab,
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
                                    if let output = result {
                                        if output.starts(with: "Outfit non valido") || output.starts(with: "Non è stato possibile") {
                                            self.outfitGenerationError = output
                                            self.generatedOutfit = ""
                                        } else {
                                            self.generatedOutfit = output
                                            self.outfitGenerationError = nil
                                        }
                                    } else {
                                        self.outfitGenerationError = "Errore nella generazione dell'outfit."
                                        self.generatedOutfit = ""
                                    }
                                }
                            }
                        },
                        errorMessage: outfitGenerationError
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
}

#if DEBUG
struct DetailView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        // Simulazione di un item osservabile
        @StateObject var previewItem = ClothingItem(
            name: "Pinocchietto",
            category: "Pantaloncino",
            macrocategory: "Pantaloni",
            imagePath: nil,
            domColor: "Borgogna",
            details: "Un pinocchietto di lana corto lungo bianco verde rosso giallo di cotone ah no di lana",
            style: "Casual",
            isFavorite: false
        )
        @State var selectedTab: Int = 0
        @State var allItems: [ClothingItem] = [
            ClothingItem(name: "Pinocchietto", category: "Pantaloncino", macrocategory: "Pantaloni", imagePath: nil, domColor: "Borgogna", details: "Un pinocchietto di lana corto lungo bianco verde rosso giallo di cotone ah no di lana", style: "Casual", isFavorite: false),
            ClothingItem(name: "Cappello", category: "Cappello", macrocategory: "Accessori", imagePath: nil, details: nil, style: "Boh", isFavorite: false)
        ]
        
        var body: some View {
            NavigationView {
                DetailView(
                    item: previewItem,
                    selectedTab: $selectedTab,
                    onDelete: {
                        print("Item eliminato in preview")
                    },
                    allItems: allItems
                )
            }
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
#endif
