import UIKit
import CoreML
import Vision

func runClassifier(on image: UIImage) -> ClassificationResult {
    guard let ciImage = CIImage(image: image) else {
        fatalError("Impossibile convertire UIImage in CIImage")
    }

    // Carica il modello Core ML
    guard let coreMLModel = try? FashionClassifier_1(configuration: MLModelConfiguration()),
          let visionModel = try? VNCoreMLModel(for: coreMLModel.model) else {
        fatalError("Impossibile caricare il modello ML")
    }

    // Variabile per salvare il risultato finale
    var classificationResult: ClassificationResult?

    // Crea la richiesta Vision con completion handler sincrono (usiamo DispatchSemaphore per aspettare)
    let semaphore = DispatchSemaphore(value: 0)

    let request = VNCoreMLRequest(model: visionModel) { request, error in
        if let results = request.results as? [VNClassificationObservation],
           let topResult = results.first {
            // Crea il risultato con i dati estratti
            classificationResult = ClassificationResult(
                category: topResult.identifier,
                style: "Unknown", // se non hai stile nel modello, metti un default
                color: "#000000"  // oppure estrai colore se previsto
            )
        } else {
            classificationResult = ClassificationResult(
                category: "Nessun risultato",
                style: "-",
                color: "#FFFFFF"
            )
        }
        semaphore.signal()
    }

    // Handler immagine
    let handler = VNImageRequestHandler(ciImage: ciImage)

    do {
        try handler.perform([request])
        // Aspetta la fine della richiesta
        semaphore.wait()
    } catch {
        print("Errore durante la classificazione: \(error)")
        return ClassificationResult(category: "Errore", style: "-", color: "#FFFFFF")
    }

    return classificationResult ?? ClassificationResult(category: "Errore", style: "-", color: "#FFFFFF")
}
