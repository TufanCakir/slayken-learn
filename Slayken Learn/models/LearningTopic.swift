import Foundation

// MARK: - Datenmodell
struct LearningTopic: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String?
    let steps: [String]
    let colors: ColorInfo
    let code: String
    let category: String
    let categoryIcon: String?
    let categoryIconColor: String?
}

struct ColorInfo: Codable {
    let backgroundColors: [String]
    let textColors: [String]
}

// MARK: - Loader (generisch & flexibel)
func loadLearningTopics(from fileName: String) -> [LearningTopic] {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        print("⚠️ \(fileName).json nicht gefunden")
        return []
    }
    do {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([LearningTopic].self, from: data)
    } catch {
        print("⚠️ Fehler beim Dekodieren von \(fileName).json: \(error)")
        return []
    }
}

// MARK: - Convenience-Funktionen
func loadSwiftData() -> [LearningTopic] {
    loadLearningTopics(from: "learningTopics")
}

func loadMetalData() -> [LearningTopic] {
    loadLearningTopics(from: "metalData")
}

func loadMetalShaderData() -> [LearningTopic] {
    loadLearningTopics(from: "metalShaderData")
}
func loadMetalAppData() -> [LearningTopic] {
    loadLearningTopics(from: "metalAppData")
}
func loadReactNativeData() -> [LearningTopic] {
    loadLearningTopics(from: "reactNativeData")
}


