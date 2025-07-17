import SwiftUI

struct HomepageView: View {
    @Binding var items: [ClothingItem]
    @Binding var selectedTab: Int
    @State private var showSettings = false
    @State private var showOutfitGenerator = false
    @State private var showWardrobe = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 32) {
                // Titolo e icona impostazioni sulla stessa riga
                HStack {
                    Text("CLOSETIQUE")
                        .font(.custom("Poppins-Bold", size: 40))
                        .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))

                    Spacer()

                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                            .padding(8)
                            .background(Color(red: 246/255, green: 232/255, blue: 234/255))
                            .clipShape(Circle())
                    }
                }
                .padding([.top, .horizontal])

                VStack(alignment: .center, spacing: 16) {
                    Button(action: {
                        showOutfitGenerator = true
                    }) {
                        AnimatedPulsingCircle(size: 290)
                    }
                    .accessibilityLabel("Genera outfit")
                }
                .frame(maxWidth: .infinity)

                Text("Genera Outfit")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("Armadio")
                    .font(.custom("Poppins-Medium", size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                    .padding(.leading)

                // Armadio Preview
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 70) {
                        if items.isEmpty {
                            Text("Nessun capo nell'armadio")
                                .foregroundColor(.secondary)
                                .padding(.vertical, 24)
                        } else {
                            ForEach(items.prefix(7), id: \.id) { item in
                                Button {
                                    selectedTab = 3 // Assicurati che la tab "Armadio" abbia index 3
                                } label: {
                                    WardrobePreviewItemView(item: item)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showWardrobe = true
                    }
                }
                .padding(.leading, 10)

                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        // FullScreenCover impostazioni
        .fullScreenCover(isPresented: $showSettings) {
            NavigationStack {
                SettingsView(items: $items, selectedTab: $selectedTab)
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Chiudi") {
                                showSettings = false
                            }
                        }
                    })
            }
        }
        // FullScreenCover generatore di outfit
        .fullScreenCover(isPresented: $showOutfitGenerator) {
            NavigationStack {
                OutfitGeneratorView(selectedTab: $selectedTab) // <--- Passa il binding!
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Chiudi") {
                                showOutfitGenerator = false
                            }
                        }
                    })
            }
        }
    }
}

// Vista per il singolo capo in preview
struct WardrobePreviewItemView: View {
    @ObservedObject var item: ClothingItem

    var body: some View {
        VStack {
            if let imageData = item.imageData,
               let data = Data(base64Encoded: imageData),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipped()
                    .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .cornerRadius(12)
                    .overlay(
                        Text("No Image")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    )
            }
            // Mostra anche la macrocategoria sotto l'immagine (opzionale)
            Text(item.macrocategory)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 90)
    }
}
