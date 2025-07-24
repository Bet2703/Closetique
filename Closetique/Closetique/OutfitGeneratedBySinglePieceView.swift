import SwiftUI

struct OutfitGeneratedBySinglePieceView: View {
    @Binding var selectedTab: Int
    let allItems: [ClothingItem]
    let aiMessage: String
    let onRegenerate: () -> Void
    let errorMessage: String?
    
    @State private var isRegenerateDisabled = false //per disabilitare il bottone Rigenera in caso di errore
    
    @State private var isPressedR = false // per il bottone Rigenera
    @State private var isPressedS = false // per il bottone Salva

    // Parsing: estrae [ClothingItem] e descrizione dal messaggio AI
    private var parsed: (items: [ClothingItem], description: String) {
        let parts = aiMessage.components(separatedBy: "|")
        guard parts.count == 2 else { return ([], "") }
        let ids = parts[0]
            .split(separator: ";")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        let selected = ids.compactMap { id in
            allItems.first(where: { $0.id.uuidString == id })
        }
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

                if let error = errorMessage, !error.isEmpty {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 28))
                        Text("Errore nella generazione dell'outfit. Riprova tra poco.")
                            .foregroundColor(.red)
                            .font(.custom("Poppins-Bold", size: 18))
                    }
                    .padding()
                    .background(Color(red:1, green:0.95, blue:0.95))
                    .cornerRadius(12)
                }
                
                // Mostra SEMPRE outfit anche se c'è errore!
                HStack(spacing: 16) {
                    ForEach(parsed.items) { item in
                        if let image = imageFromPath(item.imagePath) {
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
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(parsed.items) { item in
                        Text("\(item.name) • \(item.macrocategory) • \(item.category) • \(item.domColor ?? "-") • \(item.style)")
                            .font(.custom("Poppins-Light", size: 16))
                    }
                }

                Spacer(minLength: 50)

                VStack(spacing: 10) {
                    Divider()
                    Text(parsed.description)
                        .font(.custom("Poppins-Italic", size: 18))
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                }
                .padding(.bottom, 16)

                HStack(spacing: 24){
                    Button(action: {
                        onRegenerate()
                    }) {
                        Label("Rigenera", systemImage: "arrow.triangle.2.circlepath")
                            .font(.custom("Poppins-Regular", size: 18))
                            .foregroundColor(isRegenerateDisabled ? .black : Color(red: 112/255, green: 41/255, blue: 99/255))
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(isRegenerateDisabled ? Color(.systemGray4) : Color(red: 246/255, green: 232/255, blue: 234/255).opacity(0.5))
                            .cornerRadius(10)
                            .scaleEffect(isPressedR ? 0.87 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: isPressedR)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isPressedR { isPressedR = true }
                            }
                            .onEnded { _ in
                                isPressedR = false
                            }
                    )
                    .disabled(!(errorMessage != nil && !errorMessage!.isEmpty) ? false : isRegenerateDisabled)
                    
                    Button(action:{
                        // Salva outfit solo se ci sono items, anche se c'è errore
                        guard !parsed.items.isEmpty else { return }
                        let newOutfit = MatchOutfit(items: parsed.items, description: parsed.description)
                        UserDefaultsManager.shared.saveOutfit(newOutfit)
                        selectedTab = 1
                    }){
                        Label("Salva", systemImage: "bookmark")
                            .font(.custom("Poppins-Regular", size: 18))
                            .foregroundColor(Color(red: 246/255, green: 232/255, blue: 234/255))
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 112/255, green: 41/255, blue: 99/255))
                            .cornerRadius(10)
                            .scaleEffect(isPressedS ? 0.87 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: isPressedS)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isPressedS { isPressedS = true }
                            }
                            .onEnded { _ in
                                isPressedS = false
                            }
                    )
                    // Disabilita salva solo se NON ci sono items!
                    .disabled(parsed.items.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        // Quando compare errore, parte subito il timer per disabilitare il bottone Rigenera
        .onChange(of: errorMessage) { newValue in
            if newValue != nil && !newValue!.isEmpty {
                isRegenerateDisabled = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
                    isRegenerateDisabled = false
                }
            }
        }

    }
}

