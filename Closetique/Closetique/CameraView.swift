import SwiftUI
import UIKit

/// Vista principale che gestisce flusso: foto, classificazione, preview, salvataggio
struct CameraView: View {
    @Binding var items: [ClothingItem]
    @Environment(\.dismiss) private var dismiss

    // Stato per picker
    @State private var showImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .camera
    @State private var pickedImage: UIImage?
    // Stato per classificazione
    @State private var isClassifying: Bool = false
    @State private var classificationResult: ClassificationResult?
    @State private var showPreview: Bool = false
    // Stato per scelta sorgente
    @State private var showActionSheet = false

    var body: some View {
        VStack {
            // Se c'è preview con risultato, mostra la ClassificationPreviewView
            if let image = pickedImage, let result = classificationResult, showPreview {
                ClassificationPreviewView(
                    image: image,
                    result: result,
                    onConfirm: { updatedResult in
                        saveItem(image: image, result: updatedResult)
                        reset()
                        dismiss()
                    },
                    onRetake: {
                        reset()
                    }
                )
            } else {
                Spacer()
                // Se classificazione in corso, mostra progress
                if let image = pickedImage, isClassifying {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 320)
                        .cornerRadius(16)
                        .padding()
                    ProgressView("Analisi in corso...")
                        .padding()
                }
                // Se solo immagine, mostra preview base
                else if let image = pickedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 320)
                        .cornerRadius(16)
                        .padding()
                }
                // Se nulla, mostra bottone aggiungi foto
                else {
                    Button {
                        showActionSheet = true
                    } label: {
                        VStack {
                            Image(systemName: "camera")
                                .resizable()
                                .frame(width: 64, height: 48)
                                .padding()
                            Text("Aggiungi foto")
                                .font(.custom("Poppins-Regular", size: 16))
                        }
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .navigationTitle("Nuovo capo")
        // Dialog per scelta sorgente foto
        .confirmationDialog("Scegli sorgente", isPresented: $showActionSheet) {
            Button("Scatta foto") {
                imageSource = .camera
                showImagePicker = true
            }
            Button("Seleziona dalla galleria") {
                imageSource = .photoLibrary
                showImagePicker = true
            }
            Button("Annulla", role: .cancel) { }
        }
        // Sheet con ImagePicker
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: imageSource, selectedImage: $pickedImage, onDismiss: {
                if let img = pickedImage {
                    classify(image: img)
                }
            })
        }
    }

    /// Chiamata alla classificazione AI
    private func classify(image: UIImage) {
        isClassifying = true
        classificationResult = nil
        showPreview = false

        ImageClassifier.shared.classify(image: image) { result in
            self.classificationResult = result
            self.isClassifying = false
            self.showPreview = true
        }
    }
    
    /// Salva il capo classificato e l'immagine su disco
    private func saveItem(image: UIImage, result: ClassificationResult) {
        let id = UUID()
        let filename = "\(id).jpg"
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = directory.appendingPathComponent(filename)

        do {
            if let data = image.jpegData(compressionQuality: 0.8) {
                try data.write(to: fileURL)
            }

            let newItem = ClothingItem(
                id: id,
                name: result.category,
                category: result.category,
                macrocategory: result.macrocategory,
                imagePath: fileURL.path,
                domColor: result.domColor,
                details: result.details,
                style: result.style,
                hexColor: result.hexColor,
                isFavorite: false
            )

            items.append(newItem)
            UserDefaultsManager.shared.addItem(newItem)
            print("Immagine salvata con path: \(fileURL.path)")

        } catch {
            print("Errore nel salvataggio dell'immagine su disco: \(error)")
        }
    }

    /// Reset dello stato per ripetere la classificazione
    private func reset() {
        pickedImage = nil
        classificationResult = nil
        showPreview = false
        isClassifying = false
    }
}
