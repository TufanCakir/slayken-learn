import Foundation
internal import Combine

@MainActor
final class MissionManager: ObservableObject {

    @Published private(set) var missions: [Mission] = []
    @Published private(set) var progress: [String: Int] = [:]
    @Published private(set) var completed: Set<String> = []

    private let storageKeyProgress = "mission_progress"
    private let storageKeyCompleted = "mission_completed"
    private let storageKeyLastDailyReset = "mission_lastDailyReset"

    init() {
        loadMissions()
        loadProgress()
        autoDailyReset()
    }

    // MARK: - Mission Triggering
    func trigger(_ event: MissionEventType, account: AccountLevelManager) {
        switch event {

        case .appOpened:
            increaseProgress(for: "mission_daily_2", account: account)
        
        case .lessonCompleted:
            increaseProgress(for: "mission_daily_1", account: account)
            increaseProgress(for: "mission_weekly_1", account: account)

        case .levelChanged(let newLevel):
            if newLevel >= 5 {
                increaseProgress(for: "mission_progression_1", account: account)
            }
        }
    }

    // MARK: - Increase Progress
    private func increaseProgress(for missionID: String, account: AccountLevelManager) {
        guard !completed.contains(missionID) else { return }

        progress[missionID, default: 0] += 1
        saveProgress()

        // check completion
        if let mission = missions.first(where: { $0.id == missionID }),
           progress[missionID] ?? 0 >= mission.target {

            completed.insert(missionID)
            saveCompleted()

            account.addXP(mission.xpReward)
        }
    }

    // MARK: - Load JSON
    private func loadMissions() {
        if let url = Bundle.main.url(forResource: "mission", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Mission].self, from: data) {
            missions = decoded
        }
    }

    // MARK: - Daily Reset
    private func autoDailyReset() {
        let todayString = formattedDate(Date())

        let lastReset = UserDefaults.standard.string(forKey: storageKeyLastDailyReset)

        if lastReset != todayString {
            resetDailiesInternally()
            UserDefaults.standard.set(todayString, forKey: storageKeyLastDailyReset)
        }
    }

    private func resetDailiesInternally() {
        missions
            .filter { $0.category == "daily" }
            .forEach { mission in
                progress[mission.id] = 0
                completed.remove(mission.id)
            }
        saveProgress()
        saveCompleted()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // MARK: - Persistence
    private func saveProgress() {
        UserDefaults.standard.set(progress, forKey: storageKeyProgress)
    }

    private func saveCompleted() {
        UserDefaults.standard.set(Array(completed), forKey: storageKeyCompleted)
    }

    private func loadProgress() {
        if let saved = UserDefaults.standard.dictionary(forKey: storageKeyProgress) as? [String: Int] {
            progress = saved
        }
        if let savedCompleted = UserDefaults.standard.array(forKey: storageKeyCompleted) as? [String] {
            completed = Set(savedCompleted)
        }
    }
}
