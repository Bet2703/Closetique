//
//  AnimatedPulsingCircle.swift
//  Closetique
//
import SwiftUI

struct AnimatedPulsingCircle: View {
    @State private var animate = false
    var size : CGFloat = 290
    
    var body: some View {
        ZStack {
            Image("Button")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 290, height: 290)
                .scaleEffect(animate ? 1.08 : 0.95) // Piccola variazione per effetto "pulse"
                .animation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                    value: animate
                )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animate = true
            }
        }
    }
}

#Preview {
    AnimatedPulsingCircle(size: 150)
}
