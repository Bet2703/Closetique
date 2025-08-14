//
//  ArmocromiaMainView.swift
//  Closetique
//
import SwiftUI

/// Pagina principale della sezione Armocromia. Inizialmente mostra due pulsanti ("Inserisci la tua stazione", "Avvia test). Poi mostra la palette dell'utente
struct ArmocromiaMainView: View {
    let seasons = ["Spring", "Summer", "Autumn", "Winter"]
    
    @AppStorage("selectedSeason") private var selectedSeason: String?
    // Salva nello UserDefaults con chiave "selectedSeason" la stagione selezionata o calcolata
    
    @State private var showSeasonPicker = false // Abilita la visualizzazione del menu picker
    @State private var showTest: Bool = false // Avvia il test

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("La tua palette")
                        .font(.custom("Poppins-Bold", size: 36))
                        .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                        .padding(.horizontal)
                        .padding(.top)
                    
                    if let season = selectedSeason {
                        PaletteGridView(season: season)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            showSeasonPicker = true
                        }) {
                            HStack {
                                Image(systemName: "paintpalette.fill")
                                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                                Text("Inserisci la tua stagione")
                                    .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 246/255, green: 232/255, blue: 234/255))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        
                        Button(action: {
                            showTest = true
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .foregroundColor(.white)
                                Text("Avvia il test")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 112/255, green: 41/255, blue: 99/255))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .padding()
            .navigationDestination(isPresented: $showTest) {
                ArmocromiaTestView(onResult: { result in
                    selectedSeason = result
                    showTest = false
                })
            }
            .sheet(isPresented: $showSeasonPicker) {
                SeasonPickerView(seasons: seasons, selectedSeason: $selectedSeason)
            }
        }
    }
}

/// Struct che gestisce il menu picker per la selezione manuale della stagione
struct SeasonPickerView: View {
    let seasons: [String] // Costante passata da ArmocromiaMainView
    @Binding var selectedSeason: String? //Variabile in binding che aggiorna il valore di selectedSeason anche in ArmocromiaMainView
    
    @Environment(\.dismiss) private var dismiss // Permette di chiudere la sheet del SeasonPicker e di tornare ad ArmocromiaMainView

    var body: some View {
        NavigationStack {
            List(seasons, id: \.self) { season in
                Button(action: {
                    selectedSeason = season
                    dismiss()
                }) {
                    HStack {
                        Text(season)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedSeason == season {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .navigationTitle("Scegli la stagione")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Gestisce la visualizzazione in griglia dei colori della palette dell'utente
struct PaletteGridView: View {
    var season: String
    @State private var selectedColor: PaletteColor? = nil
    @State private var showColorPopup = false

    private var palette: ([PaletteColor], String) {
        switch season {
        case "Spring":
            return (Palette.spring, "Hai un sottotono caldo e dorato, con intensità e contrasto alti. Ti valorizzano colori accesi e caldi (verdi vivaci, rossi aranciati, rosa pesca, albicocca). Perfetti anche il cammello e il royal blu. Evita colori spenti o troppo freddi.")
        case "Summer":
            return (Palette.summer, "Hai un sottotono freddo, con intensità e contrasto bassi. Stanno bene su di te colori freddi e delicati: blu polverosi, grigi morbidi, rosa cipria e malva, verdi acqua. Da evitare i toni caldi e troppo intensi.")
        case "Autumn":
            return (Palette.autumn, "Hai un sottotono caldo, intensità e contrasto bassi. I colori ideali sono quelli caldi e terrosi: oro, ocra, marrone, oliva, arancione e rosso mattone. Il bianco crema ti dona, mentre è meglio evitare blu e colori troppo freddi.")
        case "Winter":
            return (Palette.winter, "Hai un sottotono freddo, con intensità e contrasto alti. Ti stanno bene colori freddi e brillanti: blu intensi, verdi smeraldo, bianchi ottici e ghiaccio, rossi e rosa freddi e vivaci. Evita beige e arancioni; il nero valorizza solo te!")
        default:
            return ([], "")
        }
    }

    let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Palette \(season)")
                .font(.custom("Poppins-SemiBold", size: 26))

            Text(palette.1)
                .font(.custom("Poppins-Regular", size: 18))
                .foregroundColor(.black)
                .padding(.bottom, 6)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 246/255, green: 232/255, blue: 234/255))
                )

            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(0..<palette.0.count, id: \.self) { i in
                    VStack(spacing: 6) {
                        Circle()
                            .fill(palette.0[i].color)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle().stroke(Color.gray, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.07), radius: 2, x: 0, y: 1)
                            .onTapGesture {
                                    selectedColor = palette.0[i]
                                    showColorPopup = true
                                }
                        
                        Text(palette.0[i].name)
                            .font(.custom("Poppins-Regular", size: 15))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 100)
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                }
            }
            .padding(.vertical, 2)
        }
        .padding(.vertical)
        .sheet(isPresented: $showColorPopup) {
            if let color = selectedColor {
                PaletteColorPopup(color: color)
            }
        }
    }
}

/// Gestisce la visualizzazione del popup che mostra il riquadro del colore con il suo nome esteso
struct PaletteColorPopup: View {
    let color: PaletteColor // Colore passato da PaletteGridView

    var body: some View {
        VStack(spacing: 24) {
            RoundedRectangle(cornerRadius: 24)
                .fill(color.color)
                .frame(width: 140, height: 140)
                .shadow(radius: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                )

            Text(color.name)
                .font(.custom("Poppins-SemiBold", size: 22))
                .foregroundColor(.primary)

            Spacer()
        }
        .padding()
        .presentationDetents([.fraction(0.35), .medium])
    }
}

#Preview {
    ArmocromiaMainView()
}
