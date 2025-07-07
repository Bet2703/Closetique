
//
//  OutfitGeneratorView.swift
//  Closetique
//
//  Created by Studente on 07/07/25.
//

import SwiftUI

struct OutfitGeneratorView: View {
    @State private var selectedStyle: String = "Casual"
    @State private var outfitItems: [ClothingItem] = []
    @State private var showPopup: Bool = false
    @State private var isGenerating: Bool = false
    
    let styles = ["Casual", "Elegante", "Sportivo", "Streetwear"]
    let allItems: [ClothingItem] = UserDefaultsManager.shared.loadItems()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                
                // Titolo
                HStack {
                    Text("Genera Outfit")
                        .font(.custom("Poppins-Bold", size: 40))
                        .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                    Spacer()
                }
                .padding(.horizontal)

                // Picker stile
                VStack(alignment: .leading) {
                    Text("Seleziona stile:")
                        .font(.headline)
                        .padding(.horizontal)

                    Picker("Stile", selection: $selectedStyle) {
                        ForEach(styles, id: \.self) { style in
                            Text(style).tag(style)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                Spacer()

                // Bottone di generazione stile Shazam
                HStack {
                    Spacer()
                    Button(action: {
                        generateOutfit(for: selectedStyle)
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 112/255, green: 41/255, blue: 99/255))
                                .frame(width: 200, height: 200)
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .accessibilityLabel("Genera Outfit")
                    Spacer()
                }
                Spacer()
            }
            .padding(.top)
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showPopup) {
                GeneratedOutfitPopupView(outfitItems: outfitItems, onClose: {
                    showPopup = false
                }, onRegenerate: {
                    generateOutfit(for: selectedStyle)
                })
            }
        }
    }

    func generateOutfit(for style: String) {
        isGenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Simula elaborazione AI
            let filtered = allItems.filter {
                ($0.detail ?? "").lowercased().contains(style.lowercased())
            }
            let categories = ["Maglie", "Pantaloni", "Giacche", "Scarpe", "Accessori"]
            var selected: [ClothingItem] = []

            for cat in categories {
                if let match = filtered.first(where: { $0.category == cat }) {
                    selected.append(match)
                    if selected.count >= 4 { break }
                }
            }

            outfitItems = selected
            isGenerating = false
            showPopup = true
        }
    }
}

#Preview {
    OutfitGeneratorView()
}
