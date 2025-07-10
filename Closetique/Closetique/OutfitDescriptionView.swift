import SwiftUI

struct OutfitDescriptionView: View {
    let allItems: [ClothingItem]
    let aiMessage: String

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
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 10)

                // Immagini dei capi selezionati
                HStack(spacing: 16) {
                    ForEach(parsed.items) { item in
                        if let base64 = item.imageData,
                           let data = Data(base64Encoded: base64),
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 120)
                                .cornerRadius(12)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 100, height: 120)
                                .overlay(
                                    Text(item.name.prefix(1))
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                }
                .padding(.vertical, 8)

                // Info sintetiche sui capi (opzionale)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(parsed.items) { item in
                        Text("\(item.name) • \(item.category) • \(item.domColor ?? "-") • \(item.style)")
                            .font(.subheadline)
                    }
                }

                Spacer(minLength: 40)

                // Descrizione outfit in fondo
                VStack(spacing: 12) {
                    Divider()
                    Text(parsed.description)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
