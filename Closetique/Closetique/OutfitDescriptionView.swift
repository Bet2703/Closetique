import SwiftUI

struct OutfitDescriptionView: View {
    @Binding var selectedTab: Int
    let allItems: [ClothingItem]
    let aiMessage: String
    let onRegenerate: () -> Void

    // Parsing: estrae [ClothingItem] e descrizione dal messaggio AI
    private var parsed: (items: [ClothingItem], description: String) {
        let parts = aiMessage.components(separatedBy: "|")
        guard parts.count == 2 else { return ([], "") }
        let ids = parts[0]
            .split(separator: ";")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        let selected = allItems.filter { ids.contains($0.id.uuidString) }
        let description = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
        return (selected, description)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Outfit Generato")
                    .font(.custom("Poppins-Bold", size: 40))
                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                    .padding(.top, 10)

                // Immagini dei capi selezionati
                HStack(spacing: 16) {
                    ForEach(parsed.items) { item in
                        if let image = UIImage(contentsOfFile: item.imagePath ?? "") {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 110, height: 120)
                                .cornerRadius(12)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 246/255, green: 232/255, blue: 234/255))
                                .frame(width: 110, height: 120)
                                .overlay(
                                    Text(item.name.prefix(1))
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                }
                .padding(.vertical, 10)
                
                // Info sintetiche sui capi (opzionale)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(parsed.items) { item in
                        Text("\(item.name) • \(item.macrocategory) • \(item.category) • \(item.domColor ?? "-") • \(item.style)")
                            .font(.custom("Poppins-Light", size: 16))
                    }
                }

                Spacer(minLength: 50)

                // Descrizione outfit in fondo
                VStack(spacing: 10) {
                    Divider()
                    Text(parsed.description)
                        .font(.custom("Poppins-Italic", size: 18))
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                }
                .padding(.bottom, 16)
                
                //Bottoni rigenera e salva
                HStack(spacing: 24){
                    Button(action: {
                        onRegenerate()
                    }) {
                        Label("Rigenera", systemImage: "arrow.triangle.2.circlepath")
                            .font(.custom("Poppins-Regular", size: 18))
                            .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 246/255, green: 232/255, blue: 234/255).opacity(0.5))
                            .cornerRadius(10)
                    }
                    
                    Button(action:{
                        let newOutfit = MatchOutfit(items: parsed.items, description: parsed.description)
                        UserDefaultsManager.shared.saveOutfit(newOutfit)
                        selectedTab = 1 // Cambia questo valore se la tab Armadio ha un altro indice!
                    }){
                        Label("Salva", systemImage: "bookmark")
                            .font(.custom("Poppins-Regular", size: 18))
                            .foregroundColor(Color(red: 246/255, green: 232/255, blue: 234/255))
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 112/255, green: 41/255, blue: 99/255))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
