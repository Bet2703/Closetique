//
//  DetailView.swift
//  Closetique
//
//  Created by Studente on 04/07/25.
//

import SwiftUI

struct DetailView: View {
    
    @ObservedObject var item: ClothingItem
    
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
                                    if let uiImage = imageFrom(item.imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 400, height: 450, alignment: .top)
                                            .cornerRadius(30)
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 400, height: 450)
                                            .cornerRadius(30)
                                            .overlay(Text("Nessuna immagine")
                                            .foregroundColor(.gray))
                                    }
                                    
                                    Button(action: {
                    
                                        if item.isFavorite {
                                            print("true->false")
                                            item.isFavorite = false
                                        } else {
                                            print("false->true")
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
    
    // Utility per convertire imageData (base64 o filepath) in UIImage
    func imageFrom(_ imageData: String?) -> UIImage? {
        guard let imageData = imageData else { return nil }
        // Prova a decodificare Base64
        if let data = Data(base64Encoded: imageData),
           let image = UIImage(data: data) {
            return image
        }
        // Altrimenti prova a caricare da file path
        if let image = UIImage(contentsOfFile: imageData) {
            return image
        }
        // Altrimenti prova a caricare come URL
        if let url = URL(string: imageData),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

