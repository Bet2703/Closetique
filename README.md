# 👗 Closetique

Closetique è un'app iOS sviluppata in Swift per analizzare, gestire e valorizzare il tuo guardaroba.

## 🚀 Funzionalità principali

- **Gestione guardaroba:** Aggiungi, modifica ed elimina i capi dal tuo armadio digitale con facilità.
- **Analisi foto:** Carica le foto dei tuoi vestiti per una migliore organizzazione e suggerimenti personalizzati.
- **Combinazioni per stili e palette:** Scopri nuove combinazioni di outfit in base a stili preferiti e palette di colori.
- **Analisi della stagione della pelle:** Ottieni suggerimenti sui colori più adatti a te tramite l’analisi della tua stagione cromatica personale.

## 🗝️ Configurazione delle API Keys

Per utilizzare tutte le funzionalità dell'app, è necessario inserire le chiavi API nel file `APIKEYS`.  
Assicurati di creare un file chiamato `APIKEYS` nella root del progetto e di aggiungere le tue chiavi secondo il formato richiesto dalla documentazione o dagli esempi presenti nel codice.

Esempio:
```
API_KEY_1=la_tua_chiave_api_1
API_KEY_2=la_tua_chiave_api_2
```

## 🏁 Come iniziare

1. Clona la repository:
   ```
   git clone https://github.com/Bet2703/Closetique.git
   ```
2. Inserisci le chiavi API nel file `APIKEYS` come descritto sopra.
3. Apri il progetto in Xcode.
4. Installa le dipendenze (se presenti) con CocoaPods/SPM/Cartage.
5. Compila ed esegui su un simulatore o dispositivo iOS.

## 📱 Struttura dell'app

- **ContentView:** struttura base con tab bar, gestisce la navigazione tra le principali sezioni dell’app.
- **HomepageView:** dashboard con accesso rapido alle funzionalità chiave (homepage, outfit salvati, Camera, armadio, test palette e impostazioni).
- **WardrobeView:** visualizza l’armadio e consente gestione, selezione e filtro dei capi. Include selezione multipla ed eliminazione.
- **CameraView:** gestisce l’acquisizione delle foto dei capi tramite fotocamera o galleria, e invia le immagini per la classificazione IA.
- **OutfitGeneratorView:** selezione dello stile e generazione outfit tramite IA.
- **OutfitDescriptionView:** mostra il risultato della generazione outfit, con immagini, descrizione e dettagli dei capi scelti. Permette di rigenerare o salvare l’outfit.
- **SavedOutfitsView:** storico degli outfit generati e salvati.
- **DetailView:** mostra il dettaglio di ogni capo selezionato.
- **AboutView:** presentazione dell’app e degli autori.
- **ArmocromiaMainView:** analisi della stagione cromatica dell’utente e visualizzazione delle palette colore consigliate.

---

## 🏷️ Classi principali

### Classi normali

- **ClothingItem:** modello dati per ogni capo d’abbigliamento (nome, categoria, stile, colore dominante, immagine, ecc).
- **PaletteColor:** rappresenta un colore della palette armocromatica (usata in ArmocromiaMainView).
- **ClassificationResult:** risultato della classificazione di un capo tramite IA (categoria, macrocategoria, stile, colore, ecc).
- **MatchOutfit:** modello dati per ogni outfit generato.

### Controller

- **ImageClassifier:** controller che gestisce la classificazione delle immagini dei capi. Utilizza esclusivamente **Gemini** per estrarre le feature (categoria, stile, colore, ecc.) a partire dalla foto.

---

## 🤖 Classi e servizi IA utilizzati

- **Gemini:** provider AI utilizzato tramite il controller ImageClassifier per l’estrazione delle feature dalle immagini dei capi (classificazione, colore, stile, ecc).
- **Groq (Llama 3 70B):** provider AI utilizzato per il matching degli outfit. I dati estratti da Gemini vengono inviati a Groq (con modello Llama 3 70B) per generare abbinamenti coerenti, suggerimenti e descrizioni outfit.

Le chiamate ai servizi IA sono orchestrate come segue:
- **ImageClassifier** si appoggia direttamente a Gemini per la classificazione delle immagini.
- **Groq (Llama 3 70B)** riceve le feature estratte da Gemini e si occupa della generazione/matching degli outfit e delle relative descrizioni.

---

## 👥 Sviluppatori

1. [Andrehahaha (Andrea)](https://github.com/Andrehahaha)
2. [Bet2703 (Benedetta)](https://github.com/Bet2703)
3. [gabrieledilieto1 (Gab)](https://github.com/gabrieledilieto1)

---

## 🤝 Contribuire

Contributi, segnalazioni di bug e suggerimenti sono benvenuti!
1. Fai un fork del progetto.
2. Crea un branch per la tua feature (`git checkout -b feature/NuovaFeature`)
3. Fai commit delle tue modifiche (`git commit -am 'Aggiungi nuova feature'`)
4. Fai push sul branch (`git push origin feature/NuovaFeature`)
5. Apri una Pull Request

## 📄 Licenza

Questo progetto è distribuito sotto licenza MIT. Consulta il file [LICENSE](LICENSE) per ulteriori dettagli.

---

Sviluppato con ❤️ da  
[Andrehahaha (Andrea)](https://github.com/Andrehahaha),  
[Bet2703 (Benedetta)](https://github.com/Bet2703) e  
[gabrieledilieto1 (Gab)](https://github.com/gabrieledilieto1)
