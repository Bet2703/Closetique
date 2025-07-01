//
//  ClosetiqueApp.swift
//  Closetique
//
//  Created by Studente on 01/07/25.
//

import SwiftUI

@main
struct ClosetiqueApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
