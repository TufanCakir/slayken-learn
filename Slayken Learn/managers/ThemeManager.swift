import SwiftUI
import Combine

@MainActor
final class ThemeManager: ObservableObject {
    // MARK: - Stored Properties
    @AppStorage("selectedThemeIndex") private var selectedIndex: Int = 0
    
    @Published private(set) var themes: [SlaykenTheme] = []
    @Published private(set) var groupedThemes: [String: [SlaykenTheme]] = [:]
    @Published var currentTheme: SlaykenTheme?

    // MARK: - Init
    init() {
        loadThemes()
    }

    // MARK: - Lade alle Themes aus allen JSON-Dateien
    func loadThemes() {
        // Lade alle JSON-Dateien (Slayken, Character, Seasonal, etc.)
        let all = loadAllThemes()
        themes = all
        groupedThemes = Dictionary(grouping: all, by: { $0.resolvedCategory })

        // Stelle sicher, dass ein Theme ausgewählt ist
        if themes.indices.contains(selectedIndex) {
            currentTheme = themes[selectedIndex]
        } else {
            selectedIndex = 0
            currentTheme = themes.first
        }

        print("🎨 ThemeManager: \(themes.count) Themes geladen in \(groupedThemes.keys.count) Kategorien.")
    }

    // MARK: - Theme-Auswahl
    func selectTheme(at index: Int) {
        guard themes.indices.contains(index) else { return }
        selectedIndex = index
        currentTheme = themes[index]
        print("🌈 Aktives Theme geändert zu:", currentTheme?.name ?? "Unbekannt")
    }

    // MARK: - Kategorie-Helfer
    func themes(in category: String) -> [SlaykenTheme] {
        groupedThemes[category] ?? []
    }

    var availableCategories: [String] {
        groupedThemes.keys.sorted()
    }

    // MARK: - Navigation / Utility
    func nextTheme() {
        guard !themes.isEmpty else { return }
        let nextIndex = (selectedIndex + 1) % themes.count
        selectTheme(at: nextIndex)
    }

    func resetToDefault() {
        selectedIndex = 0
        currentTheme = themes.first
        print("🔄 Theme zurückgesetzt auf:", currentTheme?.name ?? "Default")
    }

    func theme(for id: String) -> SlaykenTheme? {
        themes.first(where: { $0.id == id })
    }
}
