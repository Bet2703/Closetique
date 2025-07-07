//  GeneratedOutfitPopupView.swift
//  Closetique
//
//  Created by Studente on 07/07/25.
//
import SwiftUI

struct GeneratedOutfitPopupView: View {
    var outfitItems: [ClothingItem]
    var onClose: () -> Void
    var onRegenerate: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Outfit Generato")
                        .font(.title)
                        .bold()
                        .foregroundColor(.purple)

                    ForEach(outfitItems.prefix(4)) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            if let image = imageFrom(item.imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .cornerRadius(16)
                            }

                            HStack {
                                Text("Categoria:")
                                Spacer()
                                Text(item.category)
                            }

                            HStack {
                                Text("Colore:")
                                Spacer()
                                Circle()
                                    .fill(Color(Hex: item.domColor ?? "#AAAAAA"))
                                    .frame(width: 20, height: 20)
                                Text(item.domColor ?? "N/A")
                                    .font(.caption)
                            }

                            if let detail = item.detail, !detail.isEmpty {
                                Text("Descrizione: \(detail)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.top, 4)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    HStack(spacing: 24) {
                        Button("🔁 Rigenera") {
                            onRegenerate()
                        }
                        .foregroundColor(.purple)

                        Button("❤️ Salva") {
                            // in futuro
                        }

                        Button("✖️ Chiudi") {
                            onClose()
                        }
                        .foregroundColor(.red)
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
    }

    func imageFrom(_ imageData: String?) -> UIImage? {
        guard let imageData = imageData else { return nil }
        if let data = Data(base64Encoded: imageData),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
}
