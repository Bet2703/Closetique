//
//  ContentView.swift
//  Closetique
//
import CoreData
import SwiftUI

/// Utilizza la CustomTabBar per la navigazione tra le pagine principali dell'app
struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var items: [ClothingItem] = []
        
    var body: some View {
        VStack(spacing: 0) {
                
            Group {
                switch selectedTab {
                    case 0:
                        HomepageView(items: $items, selectedTab: $selectedTab)
                    case 1:
                        SavedOutfitsView()
                    case 2:
                        CameraView(items: $items)
                    case 3:
                        WardrobeView(items: $items, selectedTab: $selectedTab)
                    case 4:
                        ArmocromiaMainView()
                    default:
                        HomepageView(items: $items, selectedTab: $selectedTab)
                    }
            }
            .onAppear {
                items = UserDefaultsManager.shared.loadItems()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            // La TabBar resta sempre sotto
            CustomTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ContentView()
}
