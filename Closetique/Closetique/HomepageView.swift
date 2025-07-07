import SwiftUI

struct HomepageView: View {
    @State private var showSettings = false  //per il controllo della schermata

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 32) {
                   // Titolo e icona impostazioni sulla stessa riga
                   HStack {
                       Text("CLOSETIQUE")
                           .font(.custom("Poppins-Bold", size: 40))
                           .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))

                       Spacer()

                       Button(action: {
                           showSettings = true
                       }) {
                           Image(systemName: "gearshape.fill")
                               .font(.system(size: 24, weight: .bold))
                               .foregroundColor(.primary)
                               .padding(8)
                               .background(Color(.systemGray5))
                               .clipShape(Circle())
                       }
                       .fullScreenCover(isPresented: $showSettings) {
                           NavigationStack {
                               SettingsView()
                                   .toolbar {
                                       ToolbarItem(placement: .navigationBarLeading) {
                                           Button("Chiudi") {
                                               showSettings = false
                                           }
                                       }
                                   }
                           }
                       }

                   }
                   .padding([.top, .horizontal])

                VStack(alignment: .center, spacing: 16) {
                    Button(action: {
                        // Azione del bottone
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 112/255, green: 41/255, blue: 99/255))
                                .frame(width: 290, height: 290)
                            Image(systemName: "sparkles")
                                .font(.system(size: 100))
                                .foregroundColor(.white)
        VStack(alignment: .leading, spacing: 32) {
            Text("CLOSETIQUE")
                .font(.custom("Poppins-Bold", size: 40))
                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255)) // Byzantium
                .padding(.top)
                .padding(.leading)
            
            VStack(alignment: .center, spacing: 16) {
                
                Button(action: {
                    // Azione del bottone
                }) {
                    ZStack {
                        AnimatedPulsingCircle()
                    }
                }
                .accessibilityLabel("Genera outfit")
            }
            .frame(maxWidth: .infinity)
            Text("Genera Outfit")
                .font(.custom("Poppins-SemiBold", size: 27))
                .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer() // Spinge il contenuto verso l'alto
        }
        Text("Armadio")
            .font(.custom("Poppins-Medium", size: 20))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
            .padding(.leading)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                Text("No Wardrobe Item")
                Text("No Wardrobe Item")
                Text("No Wardrobe Item")
                Text("No Wardrobe Item")
                
                /*
                ForEach(wardrobeItems) { item in
                    VStack {
                        if let imageData = item.imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 120)
                                .cornerRadius(12)
                                .overlay(Text("No Image").font(.caption))
                        }
                        Text(item.name)
                            .font(.headline)
                            .lineLimit(1)
                        Text(item.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 130)
                }*/
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    HomepageView()
}
