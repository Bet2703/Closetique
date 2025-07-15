# 👗 Closetique

Benvenutə in **Closetique** – l'app iOS pensata per rivoluzionare il tuo modo di organizzare il guardaroba e creare outfit perfetti grazie all’intelligenza artificiale.

> Progetto sviluppato durante il Boot Camp **UNISA - Swift iOS**, interamente in **SwiftUI**.

---

## ✨ Funzionalità principali

🔍 **Gestione Armadio**  
- Aggiungi nuovi capi tramite fotocamera o galleria  
- Classificazione automatica con AI (categoria, colore, stile, dettagli)  
- Modifica delle informazioni prima del salvataggio  
- Visualizzazione a griglia filtrabile per categoria  
- Contrassegna i tuoi capi preferiti

🧠 **Generazione Outfit AI**  
- Scegli uno stile: Casual, Elegante, Sportivo, Streetwear  
- L’AI seleziona e combina i tuoi capi per creare outfit armoniosi  
- Visualizza i capi, una descrizione e salva il risultato

❤️ **Preferiti e Outfit Salvati**  
- Consulta facilmente i tuoi capi preferiti  
- Rivedi tutti gli outfit generati e salvati nel tempo

🛠️ **Impostazioni e Reset**  
- Pagina informazioni  
- Reset completo dell'app

---

## 📱 Struttura dell'app

- `ContentView`: struttura base con tab bar
- `HomepageView`: dashboard con accesso rapido a funzionalità chiave
- `WardrobeView`: vista armadio con gestione selezioni e filtri
- `CameraView`: acquisizione e classificazione immagini
- `OutfitGeneratorView`: selezione stile e generazione outfit AI
- `OutfitDescriptionView`: mostra il risultato dell'AI
- `SavedOutfitsView`: storico outfit salvati
- `FavoriteView`: capi contrassegnati come preferiti
- `DetailView`: dettaglio di ogni capo

---

## 🧠 AI & Persistenza

- L'AI analizza i capi e propone abbinamenti coerenti in base allo stile richiesto.
- Tutti i dati sono salvati localmente tramite `UserDefaults`.

---

## 📸 Tecnologie utilizzate

- `SwiftUI`
- `UIKit` per la fotocamera
- `UserDefaults` per la persistenza dati
- `Combine` per la gestione dello stato reattivo
- AI custom per classificazione capi e generazione outfit

---

## 🛠️ Per iniziare

1. Clona il progetto  
   ```bash
   git clone https://github.com/Bet2703/Closetique.git
   ```
2. Apri `Closetique.xcodeproj` con Xcode 15+
3. Builda e prova su simulatore o dispositivo fisico

---

## 👥 Autori

Progetto sviluppato da studenti del corso **iOS Bootcamp UNISA**, luglio 2025.  
