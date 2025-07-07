import SwiftUI

struct AnimatedPulsingCircle: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            // Cerchi concentrici animati
            /*ForEach(0..<3) { i in
                Circle()
                    .stroke(Color(red: 112/255, green: 41/255, blue: 99/255).opacity(0.3), lineWidth: 12)
                    .frame(width: 250, height: 250)
                    .scaleEffect(animate ? 1.4 : 1)
                    .opacity(animate ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: 1.8)
                            .repeatForever()
                            .delay(Double(i) * 0.5),
                        value: animate
                    )
            }*/
            // Cerchio centrale
            
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
        .onAppear { animate = true }
    }
}
