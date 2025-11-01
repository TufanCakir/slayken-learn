import SwiftUI

struct RootTabView: View {
    // MARK: - App-wide States
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.system.rawValue

    @StateObject private var themeManager = ThemeManager()
    @StateObject private var profileManager = ProfileManager()

    // MARK: - Body
    var body: some View {
        TabView {
            // 1️⃣ Lernen / Home
            NavigationStack {
                HomeView()
                    .environmentObject(themeManager)
                    .environmentObject(profileManager)
            }
            .tabItem {
                Label("Lernen", systemImage: "book.closed.fill")
            }

            // 2️⃣ Themes
            NavigationStack {
                ThemePickerScreen()
                    .environmentObject(themeManager)
            }
            .tabItem {
                Label("Themes", systemImage: "paintpalette.fill")
            }

            // 3️⃣ Profil
            NavigationStack {
                ProfileView()
                    .environmentObject(profileManager)
                    .environmentObject(themeManager)
            }
            .tabItem {
                Label("Profil", systemImage: "person.crop.circle")
            }

            // 4️⃣ Einstellungen
            NavigationStack {
                SettingsView()
                    .environmentObject(themeManager)
            }
            .tabItem {
                Label("Einstellungen", systemImage: "gearshape.fill")
            }
        }
        .preferredColorScheme(AppAppearance(rawValue: appearanceRaw)?.colorScheme)
        .environmentObject(themeManager)
        .environmentObject(profileManager)
        .task {
            await loadThemes() // async safe loading
        }
        .onAppear {
            if themeManager.currentTheme == nil {
                themeManager.currentTheme = themeManager.themes.first
            }
        }
    }

    // MARK: - Theme Loader
    private func loadThemes() async {
        // Lade alle Theme-Dateien gleichzeitig
        let loadedThemes = loadAllThemes()

    

        print("🎨 \(loadedThemes.count) Themes geladen und an ThemeManager übergeben.")
    }
}
