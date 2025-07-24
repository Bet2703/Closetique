//
//  CustomTabBar.swift
//  Closetique
//
//  Created by Studente on 24/07/25.
//

import SwiftUI

/// Gestisce il singolo item personalizzato della tab bar
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

/// Utilizza la struttura TabBarItem per creare una tab bar con simboli personalizzati
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
                systemName: "bookmark",
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
    }
}

#Preview {
    ContentView()
}
