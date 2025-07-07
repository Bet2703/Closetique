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
