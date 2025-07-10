//
//  UserDefaultsManager.swift
//  Closetique
//
//  Created by Studente on 05/07/25.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let key = "closetItems"
    
    private let savedOutfitsKey = "savedOutfits"


    private init() {}

    // Salva l'array di ClothingItem
    func saveItems(_ items: [ClothingItem]) {
        do {
            // Codifica l'array di ClothingItem in dati JSON
            let encoded = try JSONEncoder().encode(items)
            // Salva i dati in UserDefaults con la chiave specificata
            UserDefaults.standard.set(encoded, forKey: key)
        } catch {
            // Messaggio di errore in caso di problemi di codifica
            print("Errore durante la codifica degli items: \(error)")
        }
    }

    // Carica l'array di ClothingItem
    func loadItems() -> [ClothingItem] {
        // Recupera i dati salvati con la chiave specifica
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }

        do {
            // Tenta di decodificare i dati in un array di ClothingItem
            let decoded = try JSONDecoder().decode([ClothingItem].self, from: data)
            return decoded
        } catch {
            print("Errore durante la decodifica degli items: \(error)")
            return []
        }
    }

    // Aggiunge un nuovo capo
    func addItem(_ item: ClothingItem) {
        var currentItems = loadItems()
        currentItems.append(item)
        saveItems(currentItems)
    }

    // Elimina un capo
    func deleteItem(_ item: ClothingItem) {
        var currentItems = loadItems()
        currentItems.removeAll { $0.id == item.id }
        saveItems(currentItems)
    }
    
    // Resetta l'applicazione cancellando tutti i capi
    func reset(){
        UserDefaults.standard.removeObject(forKey: self.key)
    }

    // Aggiorna un capo esistente
    func updateItem(_ updatedItem: ClothingItem) {
        var currentItems = loadItems()
        if let index = currentItems.firstIndex(where: { $0.id == updatedItem.id }) {
            currentItems[index] = updatedItem
            saveItems(currentItems)
        }
    }

    //elimina un sottoinsieme di capi
    func deleteItems(_ idsToDelete: Set<UUID>) {
        var currentItems = loadItems()
        currentItems.removeAll { idsToDelete.contains($0.id) }
        saveItems(currentItems)
    }

    func saveOutfit(_ outfit: MatchOutfit) {
        var existing = loadOutfits()
        existing.append(outfit)
        do {
            let data = try JSONEncoder().encode(existing)
            UserDefaults.standard.set(data, forKey: savedOutfitsKey)
        } catch {
            print("Errore nel salvataggio outfit: \(error)")
        }
    }

    func loadOutfits() -> [MatchOutfit] {
        guard let data = UserDefaults.standard.data(forKey: savedOutfitsKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([MatchOutfit].self, from: data)
        } catch {
            print("Errore nel caricamento outfit: \(error)")
            return []
        }
    }

    // SALVA TUTTI GLI OUTFIT
    func saveOutfits(_ outfits: [MatchOutfit]) {
        do {
            let data = try JSONEncoder().encode(outfits)
            UserDefaults.standard.set(data, forKey: savedOutfitsKey)
        } catch {
            print("Errore nel salvataggio outfit: \(error)")
        }
    }

    // SALVA UNO SINGOLO (APPEND)
    func addOutfit(_ outfit: MatchOutfit) {
        var current = loadOutfits()
        current.append(outfit)
        saveOutfits(current) 
    }


}
