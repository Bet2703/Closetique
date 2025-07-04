//
//  DetailView.swift
//  Closetique
//
//  Created by Studente on 04/07/25.
//

import SwiftUI

struct DetailView: View {
    
    @State var item: ClothingItem
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    ZStack {
                        Rectangle()
                            .frame(width: 400, height: 500)
                            .foregroundColor(Color(red: 246/255, green: 232/255, blue: 234/255))
                            .cornerRadius(12)
                            .overlay(
                                ZStack(alignment: .bottomTrailing) {
                                    if let imageName = item.imageData, !imageName.isEmpty {
                                        Image(imageName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 400, height: 450, alignment: .top)
                                            .cornerRadius(30)
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 400, height: 450)
                                            .cornerRadius(30)
                                            .overlay(Text("Nessuna immagine").foregroundColor(.gray))
                                    }
                                    
                                    Button(action: {
                                        if item.isFavorite {
                                            item.isFavorite = false
                                        } else {
                                            item.isFavorite = true
                                        }
                                    }) {
                                        Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                                            .foregroundColor(item.isFavorite ? .red : .gray)
                                            .padding(10)
                                            .background(Color.white.opacity(0.8))
                                            .clipShape(Circle())
                                            .shadow(radius: 2)
                                    }
                                    .padding([.trailing, .bottom], 16)
                                }
                            )
                    }
                    
                    Text(item.name)
                        .font(.custom("Poppins-Bold", size: 30))
                        .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                    
                    Spacer()
                }
                .padding(.bottom, 160)
                .navigationTitle(item.name)
            }
            
            // Bottone "Genera Outfit"
            VStack {
                Spacer()
                Button(action: {
                    // Azione: genera outfit
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 112/255, green: 41/255, blue: 99/255))
                            .frame(width: 130, height: 130)
                        Image(systemName: "sparkles")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                }
                .accessibilityLabel("Genera Outfit")
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle(item.name)
    }
}


#Preview {


}

