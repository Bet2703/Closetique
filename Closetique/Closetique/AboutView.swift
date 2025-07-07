//
//  AboutView.swift
//  Closetique
//
//  Created by Studente on 07/07/25.
//
import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("LogoLavNoBG")
            Text("Closetique")
                .font(.custom("Poppins-Bold", size: 40))
                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
            Text("Versione 1.0\n\nClosetique è un'app per organizzare il tuo armadio, generare outfit e tenere traccia dei tuoi capi preferiti.")
                .multilineTextAlignment(.center)
                .font(.custom("Poppins-Italic", size: 18))
                .foregroundColor(Color(red: 71/255, green: 71/255, blue: 71/255))
            Spacer()
        }
        .padding()
        .navigationTitle("")
    }
}

#Preview {
    AboutView()
}


