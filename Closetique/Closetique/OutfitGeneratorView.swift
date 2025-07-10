import SwiftUI

struct OutfitGeneratorView: View {
    @State private var selectedStyle: String = "Casual"
    @State private var isGenerating: Bool = false
    @State private var generationError: String? = nil
    @State private var navigateToDescription: Bool = false
    @State private var aiMessage: String = ""

    let styles = ["Casual", "Elegante", "Sportivo", "Streetwear"]
    let allItems: [ClothingItem] = UserDefaultsManager.shared.loadItems()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Seleziona lo stile")
                    .font(.headline)
                Picker("Stile", selection: $selectedStyle) {
                    ForEach(styles, id: \.self) { style in
                        Text(style)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Spacer()

                HStack {
                    Spacer()
                    Button(action: {
                        generateOutfitWithGroq(for: selectedStyle)
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

                NavigationLink(
                    destination: OutfitDescriptionView(allItems: allItems, aiMessage: aiMessage),
                    isActive: $navigateToDescription
                ) { EmptyView() }
            }
            .padding(.top)
            .background(Color(.systemGroupedBackground))
            .alert(isPresented: Binding<Bool>(
                get: { generationError != nil },
                set: { _ in generationError = nil }
            )) {
                Alert(title: Text("Errore"), message: Text(generationError ?? ""), dismissButton: .default(Text("OK")))
            }
        }
    }

    func generateOutfitWithGroq(for style: String) {
        isGenerating = true
        generationError = nil
        LlamaGroqAPI.generateOutfitCombo(from: allItems, targetStyle: style) { result in
            DispatchQueue.main.async {
                isGenerating = false
                if let output = result {
                    self.aiMessage = output
                    self.navigateToDescription = true
                } else {
                    self.generationError = "Errore nella generazione dell'outfit."
                }
            }
        }
    }
}
