import SwiftUI

struct RootTabView: View {
    // MARK: - App-wide States
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.system.rawValue

    @StateObject private var themeManager = ThemeManager()
    @StateObject private var profileManager = ProfileManager()
    @StateObject private var purchaseManager = PurchaseManager() // 🛒 NEU

    // MARK: - Body
    var body: some View {
        TabView {
            // 1️⃣ Lernen / Home
            NavigationStack {
                HomeView()
                    .environmentObject(themeManager)
                    .environmentObject(profileManager)
                    .environmentObject(purchaseManager)
            }
            .tabItem {
                Label("Lernen", systemImage: "book.closed.fill")
            }

            // 2️⃣ Code-Shop 🛍️
            NavigationStack {
                SlaykenCodeShopView()
                    .environmentObject(themeManager)
                    .environmentObject(purchaseManager)
            }
            .tabItem {
                Label("Code-Shop", systemImage: "cart.fill")
            }

            // 3️⃣ Themes
            NavigationStack {
                ThemePickerScreen()
                    .environmentObject(themeManager)
            }
            .tabItem {
                Label("Themes", systemImage: "paintpalette.fill")
            }

            // 4️⃣ Profil
            NavigationStack {
                ProfileView()
                    .environmentObject(profileManager)
                    .environmentObject(themeManager)
            }
            .tabItem {
                Label("Profil", systemImage: "person.crop.circle")
            }
            

            // 5️⃣ Einstellungen
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
        .environmentObject(purchaseManager)
        .task {
            await loadThemes()
        }
        .onAppear {
            if themeManager.currentTheme == nil {
                themeManager.currentTheme = themeManager.themes.first
            }
        }
    }

    // MARK: - Theme Loader
    private func loadThemes() async {
        let loadedThemes = loadAllThemes()
        print("🎨 \(loadedThemes.count) Themes geladen und an ThemeManager übergeben.")
    }
}
