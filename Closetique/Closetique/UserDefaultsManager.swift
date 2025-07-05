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

    private init() {}

    // Salva l'array di ClothingItem
    func saveItems(_ items: [ClothingItem]) {
        do {
            let encoded = try JSONEncoder().encode(items)
            UserDefaults.standard.set(encoded, forKey: key)
        } catch {
            print("❌ Errore durante la codifica degli items: \(error)")
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
            print("❌ Errore durante la decodifica degli items: \(error)")
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

    // Aggiorna un capo esistente
    func updateItem(_ updatedItem: ClothingItem) {
        var currentItems = loadItems()
        if let index = currentItems.firstIndex(where: { $0.id == updatedItem.id }) {
            currentItems[index] = updatedItem
            saveItems(currentItems)
        }
    }

    // Elimina tutto
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
