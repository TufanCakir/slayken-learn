import Foundation
internal import Combine

@MainActor
final class LearningListViewModel: ObservableObject {

    @Published var topics: [LearningTopic] = []
    @Published var searchText = ""
    @Published var showFavoritesOnly = false
    @Published var selectedCategory = "Alle"
    @Published private(set) var categories: [String] = []

    let favorites: Set<String>

    init(favorites: Set<String>) {
        self.favorites = favorites
        loadTopics()
    }

    var filteredTopics: [LearningTopic] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return topics.filter { topic in
            (selectedCategory == "Alle" || topic.category == selectedCategory) &&
            (!showFavoritesOnly || favorites.contains(topic.id)) &&
            (query.isEmpty ||
             topic.title.localizedCaseInsensitiveContains(query) ||
             topic.description.localizedCaseInsensitiveContains(query))
        }
    }

    private func loadTopics() {
        let files = [
            "learningTopics", "metalData", "metalShaderData",
            "metalAppData", "reactNativeData", "purchasedContent",
            "swiftData", "arkitData", "healthkitData",
            "speechData", "visionData", "widgetkitData",
            "swiftDataModel", "htmlData", "jsonData"
        ]

        topics = files.flatMap { loadLearningTopics(from: $0) }

        let uniqueCategories = Set(topics.map(\.category))
        categories = ["Alle"] + uniqueCategories.sorted()
    }
}

