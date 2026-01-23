import SwiftUI

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            // Dark background matching the spiral background
            Color(red: 0.04, green: 0.04, blue: 0.07)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 248/255, green: 181/255, blue: 0/255).opacity(0.3),
                                    Color(red: 247/255, green: 37/255, blue: 133/255).opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 80, height: 80)

                    // System spinner
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 248/255, green: 181/255, blue: 0/255)))
                        .scaleEffect(1.8)
                }

                Text("Loading")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

#Preview {
    LoadingOverlay()
}
