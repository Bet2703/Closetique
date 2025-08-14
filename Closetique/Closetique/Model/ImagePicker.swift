//
//  ImagePicker.swift
//  Closetique
//
import SwiftUI
import UIKit

/// Wrapper SwiftUI che permette di usare UIImagePickerController per scegliere/scattare foto
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    var onDismiss: (() -> Void)? = nil

    // Crea il coordinator che gestisce i delegate UIKit
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Crea lo UIImagePickerController nativo
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    // Coordinator: gestisce callback delegate per il picker
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // Chiamato quando l'utente seleziona una foto
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true) {
                self.parent.onDismiss?()
            }
        }

        // Chiamato se l'utente annulla la selezione
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) {
                self.parent.onDismiss?()
            }
        }
    }
}
