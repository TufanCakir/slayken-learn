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

func loadDrawerSections(from fileName: String) -> [DrawerSection] {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        print("❌ Datei \(fileName).json nicht gefunden")
        return []
    }
    do {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([DrawerSection].self, from: data)
    } catch {
        print("❌ Fehler beim Laden von \(fileName): \(error)")
        return []
    }
}

