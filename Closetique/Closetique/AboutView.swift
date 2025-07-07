//
//  AboutView.swift
//  Closetique
//
//  Created by Studente on 07/07/25.
//
import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Informazioni sull'app")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.purple)
                
                Text("Closetique è un armadio virtuale intelligente che ti permette di:")
                Text("• Salvare capi fotografandoli o selezionandoli dalla galleria.")
                Text("• Classificare automaticamente i capi per categoria, stile e colore.")
                Text("• Segnare i tuoi preferiti.")
                Text("• Generare outfit abbinati grazie all'AI.")
                Text("• Modificare i dettagli di ogni capo.")
                
                Text("Progetto realizzato durante il Bootcamp iOS UNISA 2025.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .navigationTitle("About")
    }
}

#Preview {
    AboutView()
}


