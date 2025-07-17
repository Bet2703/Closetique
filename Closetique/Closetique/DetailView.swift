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

    // State temporanei per campi opzionali
    @State private var details: String = ""
    @State private var domColor: String = ""

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
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

                    TextField("Nome", text: $item.name)
                        .font(.custom("Poppins-Bold", size: 40))
                        .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        .multilineTextAlignment(.center)

                    HStack (alignment: .center) {
                        TextField("Categoria", text: $item.category)
                            .font(.custom("Poppins-Regular", size: 22))
                            .frame(maxWidth: 180)
                        Text("/")
                            .font(.custom("Poppins-Regular", size: 22))
                        Menu {
                            ForEach(availableCategories, id: \.self) { cat in
                                Button(action: {
                                    item.macrocategory = cat
                                }) {
                                    Text(cat)
                                }
                            }
                        } label: {
                            Text(item.macrocategory)
                                .font(.custom("Poppins-Regular", size: 22))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))
                                )
                        }
                        .frame(maxWidth: 180)
                    }
                    .padding(.top, 1)

                    HStack (alignment: .center){
                        Text("Stile: ")
                            .font(.custom("Poppins-SemiBold", size: 20))
                            .padding(.leading, 20)
                        TextField("Stile", text: $item.style)
                            .font(.custom("Poppins-Regular", size: 20))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 235/255, green: 235/255, blue: 235/255))
                            )
                        Spacer()
                        Text("Colore: ")
                            .font(.custom("Poppins-SemiBold", size: 20))
                        Circle()
                            .stroke(Color.gray)
                            .fill(colorFromString(domColor))
                            .frame(width: 28)
                        TextField("Colore", text: $domColor)
                            .font(.custom("Poppins-Regular", size: 20))
                            .padding(.trailing, 20)
                            .frame(width: 90)
                            .onChange(of: domColor) { newValue in
                                item.domColor = newValue
                            }
                    }

                    TextField("Dettagli", text: $details, axis: .vertical)
                        .font(.custom("Poppins-Regular", size: 20))
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3...8)
                        .onChange(of: details) { newValue in
                            item.details = newValue
                        }

                    Spacer()
                }
                .padding(.bottom, 160)
                .navigationTitle("")
                .onAppear {
                    self.details = item.details ?? ""
                    self.domColor = item.domColor ?? ""
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

    func imageFromPath(_ path: String?) -> UIImage? {
        guard let path = path else { return nil }
        return UIImage(contentsOfFile: path)
    }

    // Funzione per color dinamico
    func colorFromString(_ colorString: String?) -> Color {
        guard let colorString = colorString?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else {
            return .gray
        }
        switch colorString {
        case "verde": return .green
        case "rosso": return .red
        case "blu": return .blue
        case "giallo": return .yellow
        case "bianco": return .white
        case "nero": return .black
        case "grigio": return .gray
        default:
            // Tentativo di interpretare un hex code
            if colorString.hasPrefix("#"), let uiColor = UIColor(hex: colorString) {
                return Color(uiColor)
            }
            return .gray
        }
    }
}

// Extension UIColor per hex string se vuoi gestire codici tipo "#ececec"
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        let r, g, b, a: CGFloat
        switch hexSanitized.count {
        case 6:
            (r, g, b, a) = (CGFloat((rgb & 0xFF0000) >> 16) / 255,
                            CGFloat((rgb & 0x00FF00) >> 8) / 255,
                            CGFloat(rgb & 0x0000FF) / 255,
                            1)
        case 8:
            (r, g, b, a) = (CGFloat((rgb & 0xFF000000) >> 24) / 255,
                            CGFloat((rgb & 0x00FF0000) >> 16) / 255,
                            CGFloat((rgb & 0x0000FF00) >> 8) / 255,
                            CGFloat(rgb & 0x000000FF) / 255)
        default:
            return nil
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

#if DEBUG
struct DetailView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var exampleItems = [
            ClothingItem(name: "Pinocchietto", category: "Pantaloncino", macrocategory: "Pantaloni", imagePath: nil, domColor: "Verde", details: "Un pinocchietto di lana corto lungo bianco verde rosso giallo di cotone ah no di lana", style: "Casual", isFavorite: false),
            ClothingItem(name: "Cappello", category: "Cappello", macrocategory: "Accessori", imagePath: nil, details: nil, style: "Boh", isFavorite: false),
            ClothingItem(name: "Maglia dal gusto discutibile", category: "Maglia dal gusto discutibile", macrocategory: "Maglie", imagePath: nil, details: nil, style: "Casual", isFavorite: false),
            ClothingItem(name: "Maglia", category: "Maglia", macrocategory: "Maglie", imagePath: nil, details: nil, style: "casual", isFavorite: false)
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
