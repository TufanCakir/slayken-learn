import SwiftUI

struct RootTabView: View {
    // MARK: - App Appearance
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.system.rawValue

    // MARK: - Global Managers
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var profileManager = ProfileManager()
    @StateObject private var purchaseManager = PurchaseManager() // 🛒 In-App Käufe

    // MARK: - Body
    var body: some View {
        TabView {
            // 1️⃣ Lernen / Home
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Lernen", systemImage: "book.closed.fill")
            }

            // 2️⃣ Code-Shop 🛍️
            NavigationStack {
                SlaykenCodeShopView(preselectedProductID: nil)
            }
            .tabItem {
                Label("Code-Shop", systemImage: "cart.fill")
            }

            // 3️⃣ Themes 🎨
            NavigationStack {
                ThemePickerScreen()
            }
            .tabItem {
                Label("Themes", systemImage: "paintpalette.fill")
            }

            // 4️⃣ Profil 👤
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profil", systemImage: "person.crop.circle")
            }

            // 5️⃣ Einstellungen ⚙️
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Einstellungen", systemImage: "gearshape.fill")
            }
        }
        // MARK: - Gemeinsame Environment-Objekte
        .environmentObject(themeManager)
        .environmentObject(profileManager)
        .environmentObject(purchaseManager)

        // MARK: - App-Darstellung
        .preferredColorScheme(AppAppearance(rawValue: appearanceRaw)?.colorScheme)

        // MARK: - Initial Setup
        .task {
            initializeApp()
        }
        .onAppear(perform: ensureTheme)
    }

    // MARK: - App Setup
    private func initializeApp() {
        // Lädt Themes & initialisiert ThemeManager
        themeManager.loadThemes()
        print("🎨 Themes geladen: \(themeManager.themes.count)")
    }

    private func ensureTheme() {
        // Falls kein Theme aktiv ist → erstes wählen
        if themeManager.currentTheme == nil, let first = themeManager.themes.first {
            themeManager.currentTheme = first
            print("✅ Standardtheme gesetzt: \(first.name)")
        }
    }
}

