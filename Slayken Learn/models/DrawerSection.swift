import Foundation

struct DrawerSection: Identifiable, Codable {
    let id: String                  // Eindeutige ID für die Lektion (z. B. "swift_001")
    let title: String               // Titel der Lektion
    let description: String         // Kurzbeschreibung
    let icon: String?               // Optionales Symbol (z. B. "🔥" oder "📘")
    let steps: [String]             // Lernschritte (z. B. ["Erstelle Button", "Füge Action hinzu"])
    let colors: DrawerColor        // Farbinformationen (Hintergrund/Text)
    let code: String                // Swift-Codebeispiel (Multiline)
    let category: String            // Kategorie (z. B. "Swift", "SwiftUI", "Metal", etc.)
    let categoryIcon: String?       // Optionales Icon (z. B. "swift")
    let categoryIconColor: String?  // Optional: Farbe des Icons (z. B. "#FF6D2D")
}

struct DrawerColor: Codable {
    let backgroundColors: [String]  // Farbverlauf-Hintergrund (#000000, #FF6D2D, ...)
    let textColors: [String]        // Textfarben (z. B. ["#FFFFFF"])
}

// MARK: - Loader (generisch & flexibel)
func loadDrawerSections(from fileName: String) -> [DrawerSection] {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        print("⚠️ \(fileName).json nicht gefunden")
        return []
    }
    do {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([DrawerSection].self, from: data)
    } catch {
        print("⚠️ Fehler beim Dekodieren von \(fileName).json: \(error)")
        return []
    }
}

// MARK: - Convenience-Funktionen
func loadDrawerSwiftUIData() -> [DrawerSection] {
    loadDrawerSections(from: "drawerSections")
}

func loadDrawerSwiftData() -> [DrawerSection] {
    loadDrawerSections(from: "drawerSwiftData")
}

func loadDrawerSwiftDataModel() -> [DrawerSection] {
    loadDrawerSections(from: "drawerSwiftDataModel")
}

func loadDrawerMetalData() -> [DrawerSection] {
    loadDrawerSections(from: "drawerMetalData")
}

func loadDrawerRealityKitData() -> [DrawerSection] {
    loadDrawerSections(from: "drawerRealityKitData")
}

func loadDrawerSpriteKitData() -> [DrawerSection] {
    loadDrawerSections(from: "drawerSpriteKitData")
}

func loadDrawerARKitData() -> [DrawerSection] {
    loadDrawerSections(from: "drawerARKitData")
}

func loadDrawerWidgeKitData() -> [DrawerSection] {
    loadDrawerSections(from: "drawerWidgeKitData")
}

func loadDrawerHealthKitData() -> [DrawerSection] {
    loadDrawerSections(from: "drawerHealthKitData")
}

func loadDrawerVisionData() -> [DrawerSection] {
    loadDrawerSections(from: "drawerVisionData")
}

func loadDrawerSpeechData() -> [DrawerSection] {
    loadDrawerSections(from: "drawerSpeechData")
}

func loadDrawerHtmlData() -> [DrawerSection] {
    loadDrawerSections(from: "drawerHtmlData")
}



