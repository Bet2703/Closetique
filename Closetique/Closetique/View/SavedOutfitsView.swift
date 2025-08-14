//
//  SavedOutfitsView.swift
//  Closetique
//
import SwiftUI

/// Gestisce la visualizzazione degli outfit salvati
struct SavedOutfitsView: View {
    @State var savedOutfits: [MatchOutfit] = []

    var body: some View {
        NavigationStack {
            HStack {
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
                                // Swipe per eliminare l'item MatchOutfit
                                ForEach(savedOutfits.reversed()) { outfit in
                                    SwipeToDeleteOutfitCard(
                                        outfit: outfit,
                                        onDelete: {
                                            deleteOutfit(outfit)
                                        }
                                    )
                                }
                            }
                            .padding(.leading)
                            .padding(.trailing, 50)
                            .padding(.vertical)
                        }
                    }
                }
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 20, height: .infinity)
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                savedOutfits = UserDefaultsManager.shared.loadOutfits()
            }
        }
    }

    private func deleteOutfit(_ outfit: MatchOutfit) {
        // rimuove dall'array
        if let idx = savedOutfits.firstIndex(where: { $0.id == outfit.id }) {
            savedOutfits.remove(at: idx)
        }
        // rimuove in maniera persistente
        UserDefaultsManager.shared.deleteOutfit(outfit)
    }
}

/// Gestisce l'eliminazione dell'item MatchOutfit attraverso lo swipe
struct SwipeToDeleteOutfitCard: View {
    let outfit: MatchOutfit
    var onDelete: () -> Void

    @State private var offsetX: CGFloat = 0
    @GestureState private var isDragging = false
    private let threshold: CGFloat = 100

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete background
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        onDelete()
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .font(.title)
                        .padding()
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .padding(.trailing, 24)
            }
            OutfitCardView(outfit: outfit)
                .offset(x: offsetX)
                .gesture(
                    DragGesture()
                        .updating($isDragging) { _, state, _ in
                            state = true
                        }
                        .onChanged { value in
                            offsetX = min(0, value.translation.width)
                        }
                        .onEnded { value in
                            if abs(value.translation.width) > threshold {
                                withAnimation {
                                    onDelete()
                                }
                            } else {
                                withAnimation {
                                    offsetX = 0
                                }
                            }
                        }
                )
        }
        .animation(.spring(), value: offsetX)
    }
}

/// Gestisce la singola card di visualizzazione dell'outfit
struct OutfitCardView: View {
    let outfit: MatchOutfit

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(outfit.items) { item in
                        if let image = imageFromPath(item.imagePath) {
                                Image(uiImage: image)
                                .resizable()
                                .frame(width: 80, height: 100)
                                .cornerRadius(8)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 80, height: 100)
                                .overlay(
                                    VStack(spacing: 2) {
                                        Text(item.name)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(item.macrocategory)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                )
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

#if DEBUG
struct SavedOutfitsView_Previews: PreviewProvider {
    static var previews: some View {
        let mockItems1 = [
            ClothingItem(name: "Giacca", category: "Giacca", macrocategory: "Giacca", imagePath: nil, domColor: "Nero", details: "Giacca elegante", style: "Elegante", isFavorite: true),
            ClothingItem(name: "Pantaloni", category: "Pantaloni", macrocategory: "Pantaloni", imagePath: nil, domColor: "Grigio", details: "Slim fit", style: "Elegante", isFavorite: false),
            ClothingItem(name: "Scarpe", category: "Scarpe", macrocategory: "Scarpe", imagePath: nil, domColor: "Nero", details: "Classiche", style: "Elegante", isFavorite: false)
        ]
        let mockItems2 = [
            ClothingItem(name: "Maglione", category: "Maglie", macrocategory: "Maglie", imagePath: nil, domColor: "Blu", details: "Maglione di lana", style: "Casual", isFavorite: true),
            ClothingItem(name: "Jeans", category: "Pantaloni", macrocategory: "Pantaloni", imagePath: nil, domColor: "Blu", details: "Jeans regular", style: "Casual", isFavorite: false),
            ClothingItem(name: "Sneakers", category: "Scarpe", macrocategory: "Scarpe", imagePath: nil, domColor: "Bianco", details: "Sneakers sportive", style: "Casual", isFavorite: true)
        ]

        let mockOutfit1 = MatchOutfit(items: mockItems1, description: "Outfit elegante per una serata formale.")
        let mockOutfit2 = MatchOutfit(items: mockItems2, description: "Outfit casual per tutti i giorni.")

        SavedOutfitsView(savedOutfits: [mockOutfit1, mockOutfit2])
    }
}
#endif
