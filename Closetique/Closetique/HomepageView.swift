import SwiftUI

struct HomepageView: View {
    @State private var showSettings = false  //per il controllo della schermata
    @State private var showOutfitGenerator = false
    @State private var showWardrobe = false
    @State private var wardrobeItems: [ClothingItem] = []
    @State private var navigateToWardrobe = false
    

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
                               .font(.system(size: 30, weight: .bold))
                               .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                               .padding(8)
                               .background(Color(red: 246/255, green: 232/255, blue: 234/255))
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
                       .fullScreenCover(isPresented: $showOutfitGenerator) {
                           NavigationStack {
                               OutfitGeneratorView()
                                   .toolbar {
                                       ToolbarItem(placement: .navigationBarLeading) {
                                           Button("Chiudi") {
                                               showOutfitGenerator = false
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
                        showOutfitGenerator = true
                    }) {
                        AnimatedPulsingCircle()
                    }
                    .accessibilityLabel("Genera outfit")
                }
                .frame(maxWidth: .infinity)

                Text("Genera Outfit")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                    .frame(maxWidth: .infinity, alignment: .center)

                // Sezione Armadio + Preview
                               Text("Armadio")
                                   .font(.custom("Poppins-Medium", size: 20))
                                   .frame(maxWidth: .infinity, alignment: .leading)
                                   .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                                   .padding(.leading)

                               ScrollView(.horizontal, showsIndicators: false) {
                                   NavigationLink(destination: WardrobeView(items: UserDefaultsManager.shared.loadItems()), isActive: $navigateToWardrobe) {
                                       EmptyView()
                                   }
                                   .hidden()
                                   HStack(spacing: 16) {
                                       ForEach(wardrobeItems.prefix(5)) { item in
                                           if let image = imageFrom(item.imageData) {
                                               Image(uiImage: image)
                                                   .resizable()
                                                   .aspectRatio(contentMode: .fill)
                                                   .frame(width: 80, height: 80)
                                                   .clipped()
                                                   .cornerRadius(12)
                                           }
                                       }
                                   }
                                   .padding(.horizontal)
                                   .onTapGesture {
                                       navigateToWardrobe = true
                                   }

                               }

                               Spacer()
                           }
                           .navigationTitle("")
                           .navigationBarTitleDisplayMode(.inline)
                           .onAppear {
                               wardrobeItems = UserDefaultsManager.shared.loadItems()
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
                           .fullScreenCover(isPresented: $showOutfitGenerator) {
                               NavigationStack {
                                   OutfitGeneratorView()
                                       .toolbar {
                                           ToolbarItem(placement: .navigationBarLeading) {
                                               Button("Chiudi") {
                                                   showOutfitGenerator = false
                                               }
                                           }
                                       }
                               }
                           }
                           .fullScreenCover(isPresented: $showWardrobe) {
                               NavigationStack {
                                   WardrobeView(items: UserDefaultsManager.shared.loadItems())
                                       .toolbar {
                                           ToolbarItem(placement: .navigationBarLeading) {
                                               Button("Chiudi") {
                                                   showWardrobe = false
                                               }
                                           }
                                       }
                               }
                           }
                       }
                   }

                   func imageFrom(_ imageData: String?) -> UIImage? {
                       guard let imageData = imageData else { return nil }
                       if let data = Data(base64Encoded: imageData),
                          let image = UIImage(data: data) {
                           return image
                       }
                       return nil
                   }
               }
#Preview {
    HomepageView()
}
