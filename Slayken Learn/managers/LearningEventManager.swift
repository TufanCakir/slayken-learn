import Foundation
internal import Combine

@MainActor
final class LearningEventManager: ObservableObject {
    @Published var lessonCompletedTrigger: UUID = UUID()

    func lessonCompleted() {
        lessonCompletedTrigger = UUID()
    }
}
