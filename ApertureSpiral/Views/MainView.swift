import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            SpiralView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Spiral", systemImage: "eye")
                }
                .tag(0)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
                .tag(1)
        }
        .tint(.yellow)
    }
}

#Preview {
    MainView()
        .preferredColorScheme(.dark)
}
