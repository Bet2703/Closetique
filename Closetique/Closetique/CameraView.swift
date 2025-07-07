//
//  CameraView.swift
//  Closetique
//
//  Created by Studente on 02/07/25.
//

import SwiftUI
import UIKit

struct CameraView: View {
    
    @Binding var items: [ClothingItem]
    @Environment(\.dismiss) private var dismiss
    
    @State private var showImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .camera
    @State private var pickedImage: UIImage?
    @State private var isClassifying: Bool = false
    @State private var classificationResult: ClassificationResult?
    @State private var showPreview: Bool = false
    @State private var showActionSheet = false

    var body: some View {
        VStack {
            if let image = pickedImage, let result = classificationResult, showPreview {
                // Preview con classificazione
                ClassificationPreviewView(
                    image: image,
                    result: result,
                    onConfirm: {
                        saveItem(image: image, result: result)
                        reset()
                        dismiss()
                    },
                    onRetake: {
                        reset()
                    }
                )
            } else {
                Spacer()
                if let image = pickedImage, isClassifying {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 320)
                        .cornerRadius(16)
                        .padding()
                    ProgressView("Analisi in corso...")
                        .padding()
                } else if let image = pickedImage {
                    // Mostra comunque l'immagine finché non si avvia la classificazione
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 320)
                        .cornerRadius(16)
                        .padding()
                } else {
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
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: imageSource, selectedImage: $pickedImage, onDismiss: {
                if let img = pickedImage {
                    classify(image: img)
                }
            })
        }
    }

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
    
    private func saveItem(image: UIImage, result: ClassificationResult) {
        // Codifica l'immagine in base64
        let imageData: String? = image.jpegData(compressionQuality: 0.8)?.base64EncodedString()
        let newItem = ClothingItem(
            name: result.category, // puoi cambiare come preferisci
            category: result.category,
            imageData: imageData,
            isFavorite: false
        )
        items.append(newItem)
    }
    private func reset() {
        pickedImage = nil
        classificationResult = nil
        showPreview = false
        isClassifying = false
    }
}

// MARK: - ClassificationResult struct

struct ClassificationResult {
    var category: String
    var style: String
    var domColor: String?
    var details: String?   // ATTENZIONE: qui plurale "details"
}


// MARK: - Preview View

struct ClassificationPreviewView: View {
    let image: UIImage
    let result: ClassificationResult
    let onConfirm: () -> Void
    let onRetake: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 320)
                .cornerRadius(16)
                .padding()

            VStack(spacing: 8) {
                HStack {
                    Text("Categoria:")
                        .font(.custom("Poppins-Regular", size: 16))
                    Spacer()
                    Text(result.category).bold()
                }
                HStack {
                    Text("Stile:")
                        .font(.custom("Poppins-Regular", size: 16))
                    Spacer()
                    Text(result.style).bold()
                }
                HStack {
                    Text("Colore:")
                        .font(.custom("Poppins-Regular", size: 16))
                    Spacer()
                    Circle()
                        .fill(Color(Hex: result.domColor ?? "#CCCCCC"))
                        .frame(width: 32, height: 32)
                    Text(result.domColor ?? "N/A")
                        .font(.caption)
                }
                // Nuova riga per dettagli
                if let details = result.details, !details.isEmpty {
                    HStack {
                        Text("Dettagli:")
                            .font(.custom("Poppins-Regular", size: 16))
                        Spacer()
                        Text(details)
                            .font(.custom("Poppins-Italic", size: 14))
                            .italic()
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }

            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(12)

            HStack(spacing: 32) {
                Button("Ripeti") { onRetake() }
                    .foregroundColor(.red)
                    .bold()
                Button("Aggiungi all'armadio") { onConfirm() }
                    .foregroundColor(.green)
                    .bold()
            }
            .padding(.top)
        }
        .padding()
    }
}



// MARK: - ImagePicker (camera o galleria)

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    var onDismiss: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true) {
                self.parent.onDismiss?()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) {
                self.parent.onDismiss?()
            }
        }
    }
}

// MARK: - Preview

