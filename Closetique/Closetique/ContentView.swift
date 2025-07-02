//
//  ContentView.swift
//  Closetique
//
//  Created by Studente on 01/07/25.
//


import CoreData
import SwiftUI

    struct ContentView: View {
        @State private var selectedTab: Int = 0

        var body: some View {
            VStack(spacing: 0) {
                // Questa parte cambia in base al tab selezionato
                Group {
                    switch selectedTab {
                    case 0:
                        HomepageView()
                        /*
                    case 1:
                        FavoritesView()
                         */
                    case 2:
                        CameraView()
                         
                    case 3:
                        WardrobeView()
                        /*
                    case 4:
                        CategoriesView()
                         */
                    default:
                        HomepageView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // La TabBar resta sempre sotto
                CustomTabBar(selectedTab: $selectedTab)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabColor = Color(red: 112/255, green: 41/255, blue: 99/255) // Byzantium

    var body: some View {
        HStack {
            Spacer()
            // Home
            TabBarItem(
                systemName: "house",
                isSelected: selectedTab == 0,
                tabColor: tabColor
            ) { selectedTab = 0 }

            Spacer()
            // Star (favorites)
            TabBarItem(
                systemName: "star",
                isSelected: selectedTab == 1,
                tabColor: tabColor
            ) { selectedTab = 1 }

            Spacer()
            // Camera (ora normale)
            TabBarItem(
                systemName: "camera",
                isSelected: selectedTab == 2,
                tabColor: tabColor
            ) { selectedTab = 2 }

            Spacer()
            // Closet (armadio)
            TabBarItem(
                systemName: "square.split.2x1",
                isSelected: selectedTab == 3,
                tabColor: tabColor
            ) { selectedTab = 3 }

            Spacer()
            // Categories (dots grid)
            TabBarItem(
                systemName: "circle.grid.3x3",
                isSelected: selectedTab == 4,
                tabColor: tabColor
            ) { selectedTab = 4 }
            Spacer()
        }
        .frame(height: 80)
        .background(Color.white.shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: -2))
    }
}

struct TabBarItem: View {
    let systemName: String
    let isSelected: Bool
    let tabColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 34, height: 34)
                    .foregroundColor(isSelected ? tabColor : Color(.systemGray4))
                if isSelected {
                    Rectangle()
                        .fill(tabColor)
                        .frame(height: 4)
                        .cornerRadius(2)
                        .padding(.top, -6)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 4)
                        .cornerRadius(2)
                        .padding(.top, -6)
                }
            }
        }
    }
}
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
