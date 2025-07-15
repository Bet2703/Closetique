import SwiftUI

struct DetailView: View {
    
    @ObservedObject var item: ClothingItem
    @State var showDeleteAlert: Bool = false
    @Environment(\.dismiss) var dismiss
    var onDelete: (() -> Void)?
    
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
                                        if item.isFavorite {
                                            print("true->false")
                                            item.isFavorite = false
                                        } else {
                                            print("false->true")
                                            item.isFavorite = true
                                        }
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
                    
                    // Mostra la macrocategoria
                    Text(item.macrocategory)
                        .font(.custom("Poppins-Regular", size: 20))
                        .foregroundColor(.secondary)
                    
                    Text(item.details ?? "")
                        .font(.custom("Poppins-Regular", size: 18))
                    
                    Spacer()
                }
                .padding(.bottom, 160)
                .navigationTitle("")
                .toolbar(){
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showDeleteAlert = true
                        }){
                            Text("Elimina")
                                .foregroundStyle(Color.red)
                        }
                    }
                }.alert("Sei sicuro di voler eliminare?", isPresented: $showDeleteAlert) {
                    Button("Annulla", role: .cancel) { }
                    Button("Elimina", role: .destructive) {
                        UserDefaultsManager.shared.deleteItem(item)
                        onDelete?()
                        dismiss()
                        print("Elemento eliminato")
                    }
                } message: {
                    Text("Questa azione non può essere annullata.")
                }
            }
            
            // Bottone "Genera Outfit"
            VStack {
                Spacer()
                Button(action: {
                    // Azione: genera outfit
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
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle(item.name)
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
struct DetailView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var exampleItems = [
            ClothingItem(name: "Felpa", category: "Felpa", macrocategory: "Maglie", imageData: nil, details: "Stringa di dettagli per prova", style: "Casual", isFavorite: false),
            ClothingItem(name: "Jeans", category: "Jeans", macrocategory: "Pantaloni", imageData: nil, details: "Stringa di dettagli per prova", style: "Street", isFavorite: true),
            ClothingItem(name: "T-shirt", category: "T-shirt", macrocategory: "Maglie", imageData: nil, details: "Stringa di dettagli per prova", style: "Sport", isFavorite: false),
            ClothingItem(name: "Cintura", category: "Cintura", macrocategory: "Accessori", imageData: nil, details: "Stringa di dettagli per prova", style: "Classico", isFavorite: false),
            ClothingItem(name: "Sneakers", category: "Sneakers", macrocategory: "Scarpe", imageData: nil, details: "Stringa di dettagli per prova", style: "Urban", isFavorite: false)
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

/*#Preview {
    ContentView()
}*/
