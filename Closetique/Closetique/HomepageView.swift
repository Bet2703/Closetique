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
                        }
                    }
                    .accessibilityLabel("Genera outfit")
                }
                .frame(maxWidth: .infinity)

                Text("Genera Outfit")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("Il tuo armadio")
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
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    HomepageView()
}
