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
            let encoded = try JSONEncoder().encode(items)
            UserDefaults.standard.set(encoded, forKey: key)
        } catch {
            print("Errore durante la codifica degli items: \(error)")
        }
    }

    // Carica l'array di ClothingItem
    func loadItems() -> [ClothingItem] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }

        do {
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

    // Salva outfit
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

    // Carica outfit
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

    // Salva tutti gli outfit
    func saveOutfits(_ outfits: [MatchOutfit]) {
        do {
            let data = try JSONEncoder().encode(outfits)
            UserDefaults.standard.set(data, forKey: savedOutfitsKey)
        } catch {
            print("Errore nel salvataggio outfit: \(error)")
        }
    }

    // Elimina outfit individuale
    func deleteOutfit(_ outfit: MatchOutfit) {
        var all = loadOutfits()
        all.removeAll { $0.id == outfit.id }
        saveOutfits(all)
    }

    // Salva singolo (append)
    func addOutfit(_ outfit: MatchOutfit) {
        var current = loadOutfits()
        current.append(outfit)
        saveOutfits(current)
    }
}
