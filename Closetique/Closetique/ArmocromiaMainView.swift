import SwiftUI

struct ArmocromiaMainView: View {
    let seasons = ["Spring", "Summer", "Autumn", "Winter"]
    @AppStorage("selectedSeason") private var selectedSeason: String?
    @State private var showSeasonPicker = false
    @State private var showTest: Bool = false

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

struct PaletteColor {
    let color: Color
    let name: String
}

struct Palette {
    static let spring: [PaletteColor] = [
        PaletteColor(color: Color(red: 0.39, green: 0.22, blue: 0.20), name: "Marrone caldo"),
        PaletteColor(color: Color(red: 0.23, green: 0.43, blue: 0.48), name: "Ottanio"),
        PaletteColor(color: Color(red: 0.13, green: 0.29, blue: 0.44), name: "Blu profondo"),
        PaletteColor(color: Color(red: 0.84, green: 0.33, blue: 0.34), name: "Corallo"),
        PaletteColor(color: Color(red: 0.85, green: 0.32, blue: 0.41), name: "Rosa vivace"),
        PaletteColor(color: Color(red: 0.47, green: 0.41, blue: 0.56), name: "Viola soft"),
        PaletteColor(color: Color(red: 0.49, green: 0.26, blue: 0.23), name: "Terracotta"),
        PaletteColor(color: Color(red: 0.30, green: 0.56, blue: 0.50), name: "Verde menta"),
        PaletteColor(color: Color(red: 0.20, green: 0.40, blue: 0.62), name: "Azzurro vivace"),
        PaletteColor(color: Color(red: 0.92, green: 0.56, blue: 0.45), name: "Aragosta"),
        PaletteColor(color: Color(red: 0.90, green: 0.46, blue: 0.60), name: "Rosa pesca"),
        PaletteColor(color: Color(red: 0.38, green: 0.34, blue: 0.53), name: "Indaco"),
        PaletteColor(color: Color(red: 0.61, green: 0.52, blue: 0.34), name: "Senape"),
        PaletteColor(color: Color(red: 0.23, green: 0.60, blue: 0.41), name: "Verde prato"),
        PaletteColor(color: Color(red: 0.38, green: 0.48, blue: 0.71), name: "Blu denim"),
        PaletteColor(color: Color(red: 0.93, green: 0.70, blue: 0.66), name: "Albiccocca"),
        PaletteColor(color: Color(red: 0.92, green: 0.60, blue: 0.70), name: "Rosa antico"),
        PaletteColor(color: Color(red: 0.54, green: 0.51, blue: 0.74), name: "Lavanda"),
        PaletteColor(color: Color(red: 0.88, green: 0.62, blue: 0.48), name: "Cammello"),
        PaletteColor(color: Color(red: 0.51, green: 0.76, blue: 0.45), name: "Verde lime"),
        PaletteColor(color: Color(red: 0.38, green: 0.63, blue: 0.72), name: "Turchese"),
        PaletteColor(color: Color(red: 0.97, green: 0.77, blue: 0.45), name: "Giallo sole"),
        PaletteColor(color: Color(red: 0.97, green: 0.65, blue: 0.77), name: "Rosa bubblegum"),
        PaletteColor(color: Color(red: 0.73, green: 0.67, blue: 0.83), name: "Lilla"),
        PaletteColor(color: Color(red: 0.92, green: 0.75, blue: 0.62), name: "Crema"),
        PaletteColor(color: Color(red: 0.71, green: 0.88, blue: 0.62), name: "Verde chiaro"),
        PaletteColor(color: Color(red: 0.51, green: 0.82, blue: 0.84), name: "Azzurro polvere"),
        PaletteColor(color: Color(red: 0.97, green: 0.89, blue: 0.61), name: "Giallo chiaro"),
        PaletteColor(color: Color(red: 0.96, green: 0.77, blue: 0.81), name: "Pesca"),
        PaletteColor(color: Color(red: 0.77, green: 0.76, blue: 0.87), name: "Lavanda chiara"),
    ]
    static let summer: [PaletteColor] = [
        PaletteColor(color: Color(red: 0.11, green: 0.11, blue: 0.14), name: "Antracite"),
        PaletteColor(color: Color(red: 0.21, green: 0.22, blue: 0.30), name: "Blu notte"),
        PaletteColor(color: Color(red: 0.22, green: 0.39, blue: 0.41), name: "Azzurro polvere"),
        PaletteColor(color: Color(red: 0.73, green: 0.41, blue: 0.66), name: "Malva"),
        PaletteColor(color: Color(red: 0.50, green: 0.20, blue: 0.33), name: "Borgogna"),
        PaletteColor(color: Color(red: 0.29, green: 0.23, blue: 0.37), name: "Viola"),
        PaletteColor(color: Color(red: 0.27, green: 0.24, blue: 0.29), name: "Grigio fumo"),
        PaletteColor(color: Color(red: 0.26, green: 0.30, blue: 0.43), name: "Blu polvere"),
        PaletteColor(color: Color(red: 0.32, green: 0.49, blue: 0.50), name: "Verde acqua"),
        PaletteColor(color: Color(red: 0.94, green: 0.56, blue: 0.80), name: "Rosa cipria"),
        PaletteColor(color: Color(red: 0.64, green: 0.22, blue: 0.36), name: "Ciclamino"),
        PaletteColor(color: Color(red: 0.43, green: 0.36, blue: 0.52), name: "Viola pastello"),
        PaletteColor(color: Color(red: 0.53, green: 0.53, blue: 0.53), name: "Grigio medio"),
        PaletteColor(color: Color(red: 0.36, green: 0.45, blue: 0.71), name: "Blu carta da zucchero"),
        PaletteColor(color: Color(red: 0.40, green: 0.62, blue: 0.61), name: "Verde salvia"),
        PaletteColor(color: Color(red: 0.97, green: 0.75, blue: 0.89), name: "Rosa pallido"),
        PaletteColor(color: Color(red: 0.84, green: 0.42, blue: 0.57), name: "Rosa chiaro"),
        PaletteColor(color: Color(red: 0.49, green: 0.44, blue: 0.61), name: "Lilla scuro"),
        PaletteColor(color: Color(red: 0.80, green: 0.86, blue: 0.83), name: "Verde menta chiaro"),
        PaletteColor(color: Color(red: 0.54, green: 0.71, blue: 0.86), name: "Celeste"),
        PaletteColor(color: Color(red: 0.54, green: 0.80, blue: 0.69), name: "Verde acqua chiaro"),
        PaletteColor(color: Color(red: 0.98, green: 0.91, blue: 0.62), name: "Giallo pastello"),
        PaletteColor(color: Color(red: 0.93, green: 0.53, blue: 0.64), name: "Rosa barbie"),
        PaletteColor(color: Color(red: 0.56, green: 0.42, blue: 0.62), name: "Viola lavanda"),
        PaletteColor(color: Color(red: 0.96, green: 0.97, blue: 0.97), name: "Bianco ghiaccio"),
        PaletteColor(color: Color(red: 0.68, green: 0.85, blue: 0.98), name: "Azzurro cielo"),
        PaletteColor(color: Color(red: 0.78, green: 0.93, blue: 0.92), name: "Verde acqua pastello"),
        PaletteColor(color: Color(red: 1.00, green: 0.97, blue: 0.73), name: "Giallo crema"),
        PaletteColor(color: Color(red: 0.76, green: 0.39, blue: 0.59), name: "Rosa malva"),
        PaletteColor(color: Color(red: 0.45, green: 0.44, blue: 0.76), name: "Blu lavanda")
    ]
    static let autumn: [PaletteColor] = [
        PaletteColor(color: Color(red: 0.43, green: 0.22, blue: 0.24), name: "Mattone"),
        PaletteColor(color: Color(red: 0.89, green: 0.44, blue: 0.31), name: "Arancio bruciato"),
        PaletteColor(color: Color(red: 0.15, green: 0.23, blue: 0.14), name: "Verde bosco"),
        PaletteColor(color: Color(red: 0.29, green: 0.27, blue: 0.13), name: "Oliva"),
        PaletteColor(color: Color(red: 0.39, green: 0.20, blue: 0.23), name: "Bordeaux"),
        PaletteColor(color: Color(red: 0.48, green: 0.27, blue: 0.39), name: "Prugna"),
        PaletteColor(color: Color(red: 0.37, green: 0.22, blue: 0.23), name: "Marrone scuro"),
        PaletteColor(color: Color(red: 0.94, green: 0.70, blue: 0.27), name: "Ocra"),
        PaletteColor(color: Color(red: 0.22, green: 0.44, blue: 0.22), name: "Verde foresta"),
        PaletteColor(color: Color(red: 0.53, green: 0.25, blue: 0.19), name: "Castagna"),
        PaletteColor(color: Color(red: 0.80, green: 0.29, blue: 0.23), name: "Rosso ruggine"),
        PaletteColor(color: Color(red: 0.62, green: 0.42, blue: 0.48), name: "Malva scuro"),
        PaletteColor(color: Color(red: 0.60, green: 0.27, blue: 0.23), name: "Mattone scuro"),
        PaletteColor(color: Color(red: 0.98, green: 0.75, blue: 0.19), name: "Giallo oro"),
        PaletteColor(color: Color(red: 0.47, green: 0.70, blue: 0.44), name: "Verde oliva chiaro"),
        PaletteColor(color: Color(red: 0.92, green: 0.41, blue: 0.39), name: "Rosso corallo"),
        PaletteColor(color: Color(red: 0.66, green: 0.44, blue: 0.36), name: "Beige medio"),
        PaletteColor(color: Color(red: 0.44, green: 0.29, blue: 0.29), name: "Caffè"),
        PaletteColor(color: Color(red: 0.83, green: 0.58, blue: 0.44), name: "Crema scuro"),
        PaletteColor(color: Color(red: 0.97, green: 0.77, blue: 0.46), name: "Giallo zucca"),
        PaletteColor(color: Color(red: 0.60, green: 0.56, blue: 0.17), name: "Verde senape"),
        PaletteColor(color: Color(red: 0.96, green: 0.46, blue: 0.32), name: "Arancione acceso"),
        PaletteColor(color: Color(red: 0.95, green: 0.55, blue: 0.54), name: "Rosa antico"),
        PaletteColor(color: Color(red: 0.72, green: 0.37, blue: 0.33), name: "Mattone chiaro"),
        PaletteColor(color: Color(red: 0.76, green: 0.66, blue: 0.46), name: "Beige dorato"),
        PaletteColor(color: Color(red: 0.97, green: 0.78, blue: 0.63), name: "Crema"),
        PaletteColor(color: Color(red: 0.84, green: 0.78, blue: 0.30), name: "Verde oro"),
        PaletteColor(color: Color(red: 0.89, green: 0.34, blue: 0.17), name: "Ruggine"),
        PaletteColor(color: Color(red: 0.90, green: 0.52, blue: 0.30), name: "Arancione scuro"),
        PaletteColor(color: Color(red: 0.89, green: 0.63, blue: 0.54), name: "Beige rosato")
    ]
    static let winter: [PaletteColor] = [
        PaletteColor(color: Color(red: 0.00, green: 0.00, blue: 0.00), name: "Nero puro"),
        PaletteColor(color: Color(red: 1.00, green: 1.00, blue: 1.00), name: "Bianco puro"),
        PaletteColor(color: Color(red: 0.94, green: 0.97, blue: 1.00), name: "Bianco ghiaccio"),
        PaletteColor(color: Color(red: 0.69, green: 0.88, blue: 0.90), name: "Azzurro polare"),
        PaletteColor(color: Color(red: 0.68, green: 0.85, blue: 0.90), name: "Azzurro pastello"),
        PaletteColor(color: Color(red: 0.27, green: 0.51, blue: 0.71), name: "Blu acciaio"),
        PaletteColor(color: Color(red: 0.00, green: 0.00, blue: 0.50), name: "Blu navy"),
        PaletteColor(color: Color(red: 0.00, green: 0.20, blue: 0.40), name: "Blu notte profondo"),
        PaletteColor(color: Color(red: 0.12, green: 0.23, blue: 0.37), name: "Blu scuro intenso"),
        PaletteColor(color: Color(red: 0.00, green: 0.39, blue: 0.00), name: "Verde smeraldo"),
        PaletteColor(color: Color(red: 0.00, green: 0.54, blue: 0.54), name: "Verde acqua profondo"),
        PaletteColor(color: Color(red: 0.18, green: 0.54, blue: 0.34), name: "Verde bosco freddo"),
        PaletteColor(color: Color(red: 0.29, green: 0.00, blue: 0.51), name: "Indaco freddo"),
        PaletteColor(color: Color(red: 0.50, green: 0.00, blue: 0.50), name: "Viola intenso"),
        PaletteColor(color: Color(red: 0.29, green: 0.04, blue: 0.15), name: "Viola prugna scuro"),
        PaletteColor(color: Color(red: 0.54, green: 0.00, blue: 0.00), name: "Rosso scuro freddo"),
        PaletteColor(color: Color(red: 0.70, green: 0.13, blue: 0.13), name: "Rosso bacca"),
        PaletteColor(color: Color(red: 1.00, green: 0.08, blue: 0.58), name: "Fucsia brillante"),
        PaletteColor(color: Color(red: 0.78, green: 0.08, blue: 0.52), name: "Rosa rubino"),
        PaletteColor(color: Color(red: 0.86, green: 0.08, blue: 0.24), name: "Rosso ciliegia intenso"),
        PaletteColor(color: Color(red: 0.54, green: 0.00, blue: 0.54), name: "Magenta profondo"),
        PaletteColor(color: Color(red: 0.85, green: 0.44, blue: 0.84), name: "Lavanda chiara fredda"),
        PaletteColor(color: Color(red: 1.00, green: 0.41, blue: 0.71), name: "Rosa baby freddo"),
        PaletteColor(color: Color(red: 0.27, green: 0.51, blue: 0.71), name: "Blu acciaio (accento)"),
        PaletteColor(color: Color(red: 0.44, green: 0.50, blue: 0.56), name: "Grigio ardesia freddo"),
        PaletteColor(color: Color(red: 0.18, green: 0.31, blue: 0.31), name: "Grigio antracite scuro"),
        PaletteColor(color: Color(red: 0.66, green: 0.66, blue: 0.66), name: "Grigio medio neutro"),
        PaletteColor(color: Color(red: 0.41, green: 0.41, blue: 0.41), name: "Grigio carbone"),
        PaletteColor(color: Color(red: 0.96, green: 0.96, blue: 0.96), name: "Grafite chiarissimo"),
        PaletteColor(color: Color(red: 0.69, green: 0.77, blue: 0.87), name: "Azzurro polvere freddo")
    ]
}

struct PaletteGridView: View {
    var season: String

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
                .foregroundColor(.black)

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
                        
                        Text(palette.0[i].name)
                            .font(.custom("Poppins-Regular", size: 15))
                            .foregroundColor(.black)
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
    }
}

struct SeasonPickerView: View {
    let seasons: [String]
    @Binding var selectedSeason: String?
    @Environment(\.dismiss) private var dismiss

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

#Preview {
    ArmocromiaMainView()
}
