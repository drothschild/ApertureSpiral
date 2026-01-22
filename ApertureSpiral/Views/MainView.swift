import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            SpiralView()
                .tabItem {
                    Label("Spiral", systemImage: "eye")
                }
                .tag(0)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
                .tag(1)

            GalleryView()
                .tabItem {
                    Label("Photos", systemImage: "photo.on.rectangle")
                }
                .tag(2)
        }
        .tint(.yellow)
    }
}

#Preview {
    MainView()
        .preferredColorScheme(.dark)
}
