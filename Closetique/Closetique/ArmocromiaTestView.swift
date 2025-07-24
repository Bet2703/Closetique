//
//  ArmocromiaTestView.swift
//  Closetique
//
import SwiftUI

/// Struttura che gestisce la domanda da porre all'utente con il relativo array di alternative di risposta
struct Question {
    var text: String
    var options: [String]
}

/// Gestione del test di armocromia
struct ArmocromiaTestView: View {

    @Environment(\.dismiss) var dismiss // Gestisce il ritorno ad ArmocromiaMainView al termine del test cliccando sul bottone "Fine"
    
    @State private var currentQuestionIndex = 0 // Tiene traccia delle domande
    @State private var answers: [String] = [] // Tiene traccia delle risposte
    @State private var resultSeason: String? = nil // Memorizza la stagione calcolata con il test

    let onResult: (String) -> Void

    // Array di domande
    let questions: [Question] = [
        //sottotono caldo o freddo
        Question(text: "Come reagisce la tua pelle al sole?", options: ["Mi scotto facilmente", "Mi abbronzo facilmente"]),
        Question(text: "Qual è il colore dei gioielli che ti sembra valorizzi di più la tua carnagione?", options: ["Argento o platino", "Oro giallo o bronzo"]),
        Question(text: "Come appare la tua pelle sotto la luce del sole o delle luci artificiali?", options: ["Appare più rosata o rossastra", "Appare più dorata o olivastra"]),
        
        //sottotono freddo: estate o inverno, sottotono caldo: primavera o autunno
        Question(text: "Qual è il colore predominante dei tuoi occhi?", options: ["Blu, grigio o verde chiaro", "Marrone, nocciola o ambra"]),
        Question(text: "Qual è il colore naturale dei tuoi capelli?", options: ["Biondo cenere o castano chiaro", "Biondo chiaro o castano dorato", "Castano scuro, ramato o nero."]),
        Question(text: "Preferisci indossare colori più chiari o colori più scuri?", options: ["Colori chiari come il celeste, il rosa pallido o il grigio chiaro", "Colori scuri come il blu navy, il bordeaux o il viola scuro", "Colori chiari e pastello come il giallo chiaro, il pesca o il verde acqua.", "Colori terrosi e caldi come il marrone, l'arancione o il verde oliva."]),
        Question(text: "Com'è il contrasto tra la tua pelle e i tuoi capelli?", options: ["Basso, perchè sono bionda/o o castana/o molto chiaro e ho la pelle chiara", "Alto, perchè sono bionda/o o castana/o scuro e ho la pelle olivastra o dorata", "Basso, sono tutta chiara perché sono bionda/o, rossa/o o castana/o molto chiaro con pelle chiarissima.", "Medio, perché sono castana/o medio/intenso e pelle da media a chiara"])
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let season = resultSeason {
                    // Schermata risultato
                    Text("La tua stagione è:")
                        .font(.custom("Poppins-Medium", size: 28))
                    
                    Text(season.uppercased())
                        .font(.custom("Poppins-Bold", size: 40))
                        .foregroundColor(Color(red: 112/255, green: 41/255, blue: 99/255))
                    
                    PaletteGridView(season: season)
                    
                    Button("Fine") {
                        onResult(season)
                        dismiss()
                    }
                    .padding()
                    .background(Color(red: 112/255, green: 41/255, blue: 99/255))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.top, 30)
                } else {
                    // Domanda corrente
                    Text(questions[currentQuestionIndex].text)
                        .font(.custom("Poppins-Medium", size: 22))
                        .multilineTextAlignment(.center)
                        .padding(.top, 150)
                    
                    ForEach(questions[currentQuestionIndex].options, id: \.self) { option in
                        Button(action: {
                            answers.append(option)
                            next()
                        }) {
                            Text(option)
                                .foregroundColor(.black)
                                .frame(width: 320, height: 70)
                                .background(Color(red: 250/255, green: 232/255, blue: 234/255))
                                .cornerRadius(10)
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
            .padding()
        }
    }

    func next() {
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
        } else {
            let result = evaluateSeason(from: answers)
            resultSeason = result
        }
    }
    
    // Funzione che assegna un punto alla relativa stagione, in base alla risposte date dall'utente
    func evaluateSeason(from answers: [String]) -> String {
        var scores: [String: Int] = [
            "Spring": 0,
            "Summer": 0,
            "Autumn": 0,
            "Winter": 0
        ]

        for answer in answers {
            let lower = answer.lowercased()
            
            if lower.contains("scotto") || lower.contains("argento") || lower.contains("rosata") {
                scores["Summer", default: 0] += 1
                scores["Winter", default: 0] += 1
            }
            if lower.contains("abbronzo") || lower.contains("dorata") || lower.contains("oro") {
                scores["Spring", default: 0] += 1
                scores["Autumn", default: 0] += 1
            }
            if lower.contains("celeste") || lower.contains("cenere") || lower.contains("chiara") {
                scores["Summer", default: 0] += 1
            }
            if lower.contains("grigio") {
                scores["Summer", default: 0] += 1
                scores["Spring", default: 0] += 1
            }
            if lower.contains("bordeaux") || lower.contains("nero") || lower.contains("alto"){
                scores["Winter", default: 0] += 1
            }
            if lower.contains("pastello") || lower.contains("dorato") || lower.contains("chiarissima") {
                scores["Spring", default: 0] += 1
            }
            if lower.contains("terrosi") || lower.contains("ramato") || lower.contains("medio"){
                scores["Autumn", default: 0] += 1
            }
            if lower.contains("nocciola") {
                scores["Autumn", default: 0] += 1
                scores["Winter", default: 0] += 1
            }
            
        }

        return scores.max(by: { $0.value < $1.value })?.key ?? "Summer"
    }
}

#Preview {
    ArmocromiaMainView()
}
