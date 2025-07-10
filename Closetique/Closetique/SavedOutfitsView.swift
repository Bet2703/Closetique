//
//  SavedOutfitsView.swift
//  Closetique
//
//  Created by Studente on 10/07/25.
//

import SwiftUI

struct SavedOutfitsView: View {
    @State var savedOutfits: [MatchOutfit] = []

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                // Titolo
                Text("Outfit Salvati")
                    .font(.custom("Poppins-Bold", size: 36))
                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                    .padding(.horizontal)
                    .padding(.top)

                if savedOutfits.isEmpty {
                    Spacer()
                    Text("Nessun outfit salvato")
                        .foregroundColor(.secondary)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(savedOutfits.reversed()) { outfit in
                                NavigationLink(destination: OutfitDetailView(outfit: outfit)) {
                                    OutfitCardView(outfit: outfit)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                savedOutfits = UserDefaultsManager.shared.loadOutfits()
            }
        }
    }
}

struct OutfitCardView: View {
    let outfit: MatchOutfit

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(outfit.items) { item in
                        if let base64 = item.imageData,
                           let data = Data(base64Encoded: base64),
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 80, height: 100)
                                .cornerRadius(8)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 80, height: 100)
                        }
                    }
                }
            }

            if let description = outfit.description, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(3)
            }

            Text(outfit.dateCreated.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct OutfitDetailView: View {
    let outfit: MatchOutfit

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Outfit")
                    .font(.largeTitle)
                    .bold()

                HStack(spacing: 12) {
                    ForEach(outfit.items) { item in
                        if let base64 = item.imageData,
                           let data = Data(base64Encoded: base64),
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 100, height: 120)
                                .cornerRadius(10)
                        }
                    }
                }

                if let description = outfit.description {
                    Text(description)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                }

                Text("Creato il \(outfit.dateCreated.formatted(date: .long, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Dettagli Outfit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/*
#Preview {
    SavedOutfitsView()
}
 */

#if DEBUG
struct SavedOutfitsView_Previews: PreviewProvider {
    static var previews: some View {
        let mockItems = [
            ClothingItem(name: "Giacca", category: "Giacche", imageData: nil, domColor: "Nero", details: "Giacca elegante", style: "Elegante", isFavorite: false),
            ClothingItem(name: "Pantaloni", category: "Pantaloni", imageData: nil, domColor: "Grigio", details: "Slim fit", style: "Elegante", isFavorite: false),
            ClothingItem(name: "Scarpe", category: "Scarpe", imageData: nil, domColor: "Nero", details: "Classiche", style: "Elegante", isFavorite: false)
        ]

        let mockOutfit1 = MatchOutfit(items: mockItems, description: "Outfit elegante per una serata formale.")
        let mockOutfit2 = MatchOutfit(items: mockItems.reversed(), description: "Alternativa casual elegante.")

        SavedOutfitsView(savedOutfits: [mockOutfit1, mockOutfit2])
    }
}
#endif

