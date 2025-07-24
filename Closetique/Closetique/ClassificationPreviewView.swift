import SwiftUI

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
                // Categoria
                HStack {
                    Text("Categoria:").font(.custom("Poppins-Regular", size: 16))
                    Spacer()
                    if editingField == .category {
                        TextField("Categoria", text: $editedCategory)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                        Button(action: { editingField = nil }) {
                            Image(systemName: "checkmark").font(.system(size: 20, weight: .bold)).foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        }
                    } else {
                        Text(editedCategory.isEmpty ? result.category : editedCategory).bold()
                        Button(action: {
                            editedCategory = result.category
                            editingField = .category
                        }) {
                            Image(systemName: "pencil").font(.system(size: 20, weight: .bold)).foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        }
                    }
                }
                // Macrocategoria
                HStack {
                    Text("Macrocategoria:").font(.custom("Poppins-Regular", size: 16))
                    Spacer()
                    if editingField == .macrocategory {
                        Picker("Macrocategoria", selection: $editedMacrocategory) {
                            ForEach(availableCategories, id: \.self) { cat in
                                Text(cat)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        Button(action: { editingField = nil }) {
                            Image(systemName: "checkmark").font(.system(size: 20, weight: .bold)).foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        }
                    } else {
                        Text(editedMacrocategory.isEmpty ? result.macrocategory : editedMacrocategory).bold()
                        Button(action: {
                            editedMacrocategory = result.macrocategory
                            editingField = .macrocategory
                        }) {
                            Image(systemName: "pencil").font(.system(size: 20, weight: .bold)).foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        }
                    }
                }
                // Stile
                HStack {
                    Text("Stile:").font(.custom("Poppins-Regular", size: 16))
                    Spacer()
                    if editingField == .style {
                        TextField("Stile", text: $editedStyle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                        Button(action: { editingField = nil }) {
                            Image(systemName: "checkmark").font(.system(size: 20, weight: .bold)).foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        }
                    } else {
                        Text(editedStyle.isEmpty ? result.style : editedStyle).bold()
                        Button(action: {
                            editedStyle = result.style
                            editingField = .style
                        }) {
                            Image(systemName: "pencil").font(.system(size: 20, weight: .bold)).foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        }
                    }
                }
                // Colore
                HStack {
                    Text("Colore:").font(.custom("Poppins-Regular", size: 16))
                    Spacer()
                    Circle().fill(Color(Hex: result.hexColor)).frame(width: 32, height: 32)
                    Text(editedDomColor.isEmpty ? result.domColor : editedDomColor).font(.custom("Poppins-Regular", size: 16))
                }
                // Dettagli
                HStack(alignment: .top) {
                    Text("Dettagli:").font(.custom("Poppins-Regular", size: 16))
                    Spacer()
                    if editingField == .details {
                        TextField("Dettagli", text: $editedDetails)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 160)
                        Button(action: { editingField = nil }) {
                            Image(systemName: "checkmark").font(.system(size: 20, weight: .bold)).foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
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
                            Image(systemName: "pencil").font(.system(size: 20, weight: .bold)).foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
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
