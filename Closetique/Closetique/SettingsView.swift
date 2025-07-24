//
//  SettingsView.swift
//  Closetique
//
import SwiftUI

/// Gestisce la pagina delle impostazioni, dalla quale è possibile visualizzare le informazioni dell'app ed effettuare il reset
struct SettingsView: View {
    @State private var showResetAlert = false
    @Binding var items: [ClothingItem]
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0){
                Text("Impostazioni")
                    .font(.custom("Poppins-Bold", size: 35))
                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                    .padding(.leading)
                List {
                    NavigationLink(destination: AboutView()) {
                        Label("Informazioni", systemImage: "info.circle")
                            .font(.custom("Poppins-Regular", size: 18))
                    }

                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Reset App", systemImage: "trash")
                            .font(.custom("Poppins-Regular", size: 18))
                    }
                }
            }
            .navigationTitle("")
            
            .alert("Sei sicuro di voler resettare l'app?", isPresented: $showResetAlert) {
                Button("Annulla", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    items.removeAll()
                    UserDefaultsManager.shared.reset()
                    selectedTab = 0
                }
            } message: {
                Text("Tutti i capi salvati verranno eliminati. L'operazione è irreversibile.")
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var items: [ClothingItem] = [
            ClothingItem(name: "Felpa", category: "Felpa", macrocategory: "Maglie", imagePath: nil, style: "Casual", isFavorite: false),
            ClothingItem(name: "Jeans", category: "Jeans", macrocategory: "Pantaloni", imagePath: nil, style: "Street", isFavorite: true)
        ]
        @State var selectedTab: Int = 0
        
        var body: some View {
            SettingsView(items: $items, selectedTab: $selectedTab)
        }
    }
    return PreviewWrapper()
}
