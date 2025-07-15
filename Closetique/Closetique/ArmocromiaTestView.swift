//
//  ArmocromiaTestView.swift
//  Closetique
//
//  Created by Studente on 15/07/25.
//

import SwiftUI

struct ArmocromiaTestView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentQuestionIndex = 0
    @State private var answers: [String] = []
    @State private var resultSeason: String? = nil

    let onResult: (String) -> Void

    let questions: [Question] = [
        Question(text: "Come reagisce la tua pelle al sole?", options: ["Si abbronza facilmente", "Si scotta subito"]),
        Question(text: "Hai lentiggini?", options: ["Sì", "No"]),
        Question(text: "La tua pelle si arrossa facilmente?", options: ["Sì, spesso", "No, raramente"]),
        Question(text: "Che tipo di pelle hai?", options: ["Chiara e delicata", "Olivastra o dorata"]),
        Question(text: "Di che colore sono i tuoi occhi?", options: ["Chiari (azzurri, verdi)", "Scuri (marroni, neri)"]),
        Question(text: "Usi il rossetto?", options: ["Sì, spesso", "No, raramente"]),
        Question(text: "Come sono le tue sopracciglia?", options: ["Chiare e sottili", "Scure e marcate"]),
        Question(text: "Di che colore hai la sclera (parte bianca degli occhi)?", options: ["Molto bianca", "Tendente al crema"]),
        Question(text: "Hai mai tinto i capelli? Se sì, come reagiscono al colore?", options: ["Assorbono bene il colore", "Sbiadiscono o cambiano tono"])
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
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
                    
                    ForEach(questions[currentQuestionIndex].options, id: \.self) { option in
                        Button(option) {
                            answers.append(option)
                            next()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink.opacity(0.2))
                        .cornerRadius(10)
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

    func evaluateSeason(from answers: [String]) -> String {
        var scores: [String: Int] = [
            "Spring": 0,
            "Summer": 0,
            "Autumn": 0,
            "Winter": 0
        ]

        for answer in answers {
            let lower = answer.lowercased()

            if lower.contains("abbronza") || lower.contains("dorata") || lower.contains("assorbono") {
                scores["Spring", default: 0] += 2
                scores["Autumn", default: 0] += 1
            }
            if lower.contains("scotta") || lower.contains("chiara") || lower.contains("arrossa") {
                scores["Summer", default: 0] += 2
                scores["Winter", default: 0] += 1
            }
            if lower.contains("olivastra") || lower.contains("crema") || lower.contains("tendente al crema") {
                scores["Autumn", default: 0] += 2
                scores["Spring", default: 0] += 1
            }
            if lower.contains("scure") || lower.contains("marroni") || lower.contains("neri") || lower.contains("marcate") {
                scores["Winter", default: 0] += 2
                scores["Autumn", default: 0] += 1
            }
            if lower.contains("chiare") || lower.contains("azzurri") || lower.contains("verdi") || lower.contains("sottili") {
                scores["Summer", default: 0] += 2
                scores["Spring", default: 0] += 1
            }
            if lower.contains("molto bianca") {
                scores["Winter", default: 0] += 2
            }
            if lower.contains("sbiadiscono") || lower.contains("cambiano tono") {
                scores["Summer", default: 0] += 1
                scores["Winter", default: 0] += 2
            }
            if lower.contains("rossetto") {
                scores["Winter", default: 0] += 1
                scores["Spring", default: 0] += 1
            }
        }

        return scores.max(by: { $0.value < $1.value })?.key ?? "Summer"
    }

    struct Question {
        var text: String
        var options: [String]
    }
}
