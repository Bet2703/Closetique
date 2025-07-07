//
//  SettingsView.swift
//  Closetique
//
//  Created by Studente on 07/07/25.
//
import SwiftUI

struct SettingsView: View {
    @State private var showResetAlert = false
    @State private var items: [ClothingItem] = []

    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: AboutView()) {
                    Label("Informazioni", systemImage: "info.circle")
                }

                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("Reset App", systemImage: "trash")
                }
            }
            .navigationTitle("Impostazioni")
            .alert("Sei sicuro di voler resettare l'app?", isPresented: $showResetAlert) {
                Button("Annulla", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    items.removeAll()
                    UserDefaultsManager.shared.saveItems([])
                }
            } message: {
                Text("Tutti i capi salvati verranno eliminati. L'operazione è irreversibile.")
            }
        }
    }
}

#Preview {
    SettingsView()
}
