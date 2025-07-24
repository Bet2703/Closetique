import SwiftUI

struct OutfitGeneratorView: View {
    @Binding var selectedTab: Int
    @State private var selectedStyle: String = "Casual"
    @State private var isGenerating: Bool = false
    @State private var generationError: String? = nil
    @State private var navigateToDescription: Bool = false
    @State private var aiMessage: String = ""
    @State private var includePalette: Bool = false
    @AppStorage("selectedSeason") private var selectedSeason: String?
    @State private var showPaletteAlert = false
    @State private var goToPaletteView = false
    @State private var insertStyle = ""
    
    let styles = ["Casual", "Elegante", "Sportivo", "Streetwear"]
    let allItems: [ClothingItem] = UserDefaultsManager.shared.loadItems()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Seleziona lo stile")
                    .font(.custom("Poppins-SemiBold", size: 32))
                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                Picker("Stile", selection: $selectedStyle) {
                    ForEach(styles, id: \.self) { style in
                        Text(style)
                            .font(.custom("Poppins-Regular", size: 20))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .scaleEffect(CGSize(width: 1, height: 1.3))
                
                HStack {
                    TextField("Inserisci lo stile...", text: $insertStyle)
                        .foregroundColor(.black)
                        .autocapitalization(.none)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal)

                Spacer()

                HStack {
                    Spacer()
                    Button(action: {
                        if insertStyle == "" {
                            generateOutfitWithGroq(for: selectedStyle)
                            insertStyle = ""
                        } else {
                            generateOutfitWithGroq(for: insertStyle)
                            insertStyle = ""
                        }
                    }) {
                        AnimatedPulsingCircle(size: 200)
                    }
                    .accessibilityLabel("Genera Outfit")
                    Spacer()
                }
                Spacer()

                HStack {
                    Toggle(isOn: Binding(
                        get: { includePalette },
                        set: { newValue in
                            if newValue && selectedSeason == nil {
                                showPaletteAlert = true
                            } else {
                                includePalette = newValue
                            }
                        }
                    )) {
                        Text("Includi palette di colori nella generazione dell'outfit")
                            .font(.custom("Poppins-Regular", size: 20))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color(red: 112/255, green: 41/255, blue: 99/255)))
                }
                .padding(20)

                NavigationLink(
                    destination: OutfitDescriptionView(
                        selectedTab: $selectedTab,
                        allItems: allItems,
                        aiMessage: aiMessage,
                        onRegenerate: {
                            generateOutfitWithGroq(for: selectedStyle)
                        },
                        errorMessage: generationError
                    ),
                    isActive: $navigateToDescription
                ) { EmptyView() }

                NavigationLink(destination: ArmocromiaMainView(), isActive: $goToPaletteView) {
                    EmptyView()
                }
            }
            .padding(.top)
            .background(Color(.systemGroupedBackground))
            .alert(isPresented: Binding<Bool>(
                get: { generationError != nil },
                set: { _ in generationError = nil }
            )) {
                Alert(title: Text("Errore"), message: Text(generationError ?? ""), dismissButton: .default(Text("OK")))
            }
            .alert("Palette non selezionata", isPresented: $showPaletteAlert) {
                Button("Vai al test") {
                    goToPaletteView = true
                }
                Button("Annulla", role: .cancel) {}
            } message: {
                Text("Per includere la palette nei suggerimenti, devi prima completare il test di armocromia.")
            }
        }
    }

    func generateOutfitWithGroq(for style: String) {
        isGenerating = true
        generationError = nil
        LlamaGroqAPI.generateOutfitCombo(
            from: allItems,
            targetStyle: style,
            includePalette: includePalette
        ) { result in
            DispatchQueue.main.async {
                isGenerating = false
                if let output = result {
                    if output.starts(with: "Outfit non valido")
                        || output.starts(with: "Non è stato possibile")
                        || output.starts(with: "Errore API:")
                        || output.starts(with: "Errore di rete")
                        || output.starts(with: "Errore:")
                    {
                        self.generationError = output
                        self.aiMessage = ""
                        self.navigateToDescription = true
                    } else {
                        self.aiMessage = output
                        self.generationError = nil
                        self.navigateToDescription = true
                    }
                } else {
                    self.generationError = "Errore sconosciuto: nessuna risposta dalla API!"
                    self.aiMessage = ""
                    self.navigateToDescription = true
                }
            }
        }
    }
}
