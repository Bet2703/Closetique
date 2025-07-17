import SwiftUI
import UIKit

// MARK: - ClassificationResult struct

struct ClassificationResult {
    let category: String
    let macrocategory: String
    let style: String
    let domColor: String
    let details: String
    let hexColor: String
}

// MARK: - CameraView

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
                // Preview con classificazione e possibilità di modifica
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

    private func reset() {
        pickedImage = nil
        classificationResult = nil
        showPreview = false
        isClassifying = false
    }
}

// MARK: - ClassificationPreviewView

struct ClassificationPreviewView: View {
    let image: UIImage
    let result: ClassificationResult
    let onConfirm: (ClassificationResult) -> Void
    let onRetake: () -> Void
    let availableCategories: [String] = ["Maglie", "Camicie", "Pantaloni", "Gonne", "Abiti", "Giacca", "Giubbino", "Cappotto", "Scarpe", "Accessori", "Extra"]

    // Editing states
    @State private var editedCategory: String = ""
    @State private var editedMacrocategory: String = ""
    @State private var editedStyle: String = ""
    @State private var editedDomColor: String = ""
    @State private var editedDetails: String = ""
    @State private var editingField: EditingField? = nil
    @State private var isSaving = false

    enum EditingField { case category, macrocategory, style, domColor, details }

    var body: some View {
        VStack(spacing: 24) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 320)
                .cornerRadius(16)
                .padding()

            VStack(spacing: 12) {
                // Categoria specifica: modificabile tramite TextField
                HStack {
                    Text("Categoria:")
                        .font(.custom("Poppins-Regular", size: 16))
                    Spacer()
                    if editingField == .category {
                        TextField("Categoria", text: $editedCategory)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                        Button(action: { editingField = nil }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        }
                    } else {
                        Text(editedCategory.isEmpty ? result.category : editedCategory)
                            .bold()
                        Button(action: {
                            editedCategory = result.category
                            editingField = .category
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        }
                    }
                }

                // Macrocategoria: modificabile tramite Picker (enum)
                HStack {
                    Text("Macrocategoria:")
                        .font(.custom("Poppins-Regular", size: 16))
                    Spacer()
                    if editingField == .macrocategory {
                        Picker("Macrocategoria", selection: $editedMacrocategory) {
                            ForEach(availableCategories, id: \.self) { cat in
                                Text(cat)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        Button(action: { editingField = nil }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        }
                    } else {
                        Text(editedMacrocategory.isEmpty ? result.macrocategory : editedMacrocategory)
                            .bold()
                        Button(action: {
                            editedMacrocategory = result.macrocategory
                            editingField = .macrocategory
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        }
                    }
                }

                // Stile: modificabile tramite TextField
                HStack {
                    Text("Stile:")
                        .font(.custom("Poppins-Regular", size: 16))
                    Spacer()
                    if editingField == .style {
                        TextField("Stile", text: $editedStyle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                        Button(action: { editingField = nil }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        }
                    } else {
                        Text(editedStyle.isEmpty ? result.style : editedStyle)
                            .bold()
                        Button(action: {
                            editedStyle = result.style
                            editingField = .style
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        }
                    }
                }

                // Colore: modificabile tramite TextField
                HStack {
                    Text("Colore:")
                        .font(.custom("Poppins-Regular", size: 16))
                    Spacer()
                    Circle()
                        .fill(Color(Hex: result.hexColor))
                        .frame(width: 32, height: 32)
                    Text(editedDomColor.isEmpty ? result.domColor : editedDomColor)
                        .font(.custom("Poppins-Regular", size: 16))
                }

                // Dettagli: modificabile tramite TextField
                HStack(alignment: .top) {
                    Text("Dettagli:")
                        .font(.custom("Poppins-Regular", size: 16))
                    Spacer()
                    if editingField == .details {
                        TextField("Dettagli", text: $editedDetails)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 160)
                        Button(action: { editingField = nil }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        }
                    } else {
                        Text(editedDetails.isEmpty ? result.details : editedDetails)
                            .font(.custom("Poppins-Italic", size: 14))
                            .italic()
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.trailing)
                        Button(action: {
                            editedDetails = result.details
                            editingField = .details
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        }
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
                Button("Aggiungi all'armadio") {
                    isSaving = true
                    let newResult = ClassificationResult(
                        category: editedCategory.isEmpty ? result.category : editedCategory,
                        macrocategory: editedMacrocategory.isEmpty ? result.macrocategory : editedMacrocategory,
                        style: editedStyle.isEmpty ? result.style : editedStyle,
                        domColor: editedDomColor.isEmpty ? result.domColor : editedDomColor,
                        details: editedDetails.isEmpty ? result.details : editedDetails,
                        hexColor: result.hexColor
                    )
                    onConfirm(newResult)
                }
                .foregroundColor(.green)
                .bold()
                .disabled(isSaving)
            }
            .padding(.top)
        }
        .padding()
    }
}

// MARK: - ImagePicker

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

#Preview{
    ContentView()
}
