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
    private let storageKeyLastWeeklyReset = "mission_lastWeeklyReset"

    init() {
        loadMissions()
        loadProgress()
        autoDailyReset()
        autoWeeklyReset()
    }

    // MARK: - Mission Triggering
    func trigger(_ event: MissionEventType, account: AccountLevelManager) {

        switch event {

        case .appOpened:
            increaseProgress(for: "mission_daily_2", account: account)
            increaseProgress(for: "mission_weekly_2", account: account)

        case .lessonCompleted:
            increaseProgress(for: "mission_daily_1", account: account)
            increaseProgress(for: "mission_weekly_1", account: account)
            increaseProgress(for: "mission_progression_4", account: account)

        case .lessonRepeated:
            increaseProgress(for: "mission_weekly_4", account: account)

        case .lessonShared:
            increaseProgress(for: "mission_daily_3", account: account)

        case .categoryOpened:
            increaseProgress(for: "mission_daily_5", account: account)

        case .learningMinutes(let minutes):
            addProgress(minutes, for: "mission_daily_4", account: account)

        case .xpGained(let xp):
            addProgress(xp, for: "mission_weekly_3", account: account)
            addProgress(xp, for: "mission_progression_3", account: account)

        case .levelChanged(let newLevel):
            setProgress(newLevel, for: "mission_progression_1", account: account)
            setProgress(newLevel, for: "mission_progression_2", account: account)
        }
    }

    // MARK: - Progress Helpers
    private func increaseProgress(for missionID: String, account: AccountLevelManager) {
        addProgress(1, for: missionID, account: account)
    }

    private func addProgress(_ amount: Int, for missionID: String, account: AccountLevelManager) {
        guard !completed.contains(missionID) else { return }

        progress[missionID, default: 0] += amount
        evaluateMission(missionID, account: account)
    }

    private func setProgress(_ value: Int, for missionID: String, account: AccountLevelManager) {
        guard !completed.contains(missionID) else { return }

        progress[missionID] = value
        evaluateMission(missionID, account: account)
    }

    private func evaluateMission(_ missionID: String, account: AccountLevelManager) {
        saveProgress()

        guard let mission = missions.first(where: { $0.id == missionID }) else { return }

        if (progress[missionID] ?? 0) >= mission.target {
            completed.insert(missionID)
            saveCompleted()
            account.addXP(mission.xpReward)
        }
    }

    // MARK: - JSON
    private func loadMissions() {
        guard
            let url = Bundle.main.url(forResource: "mission", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([Mission].self, from: data)
        else { return }

        missions = decoded
    }

    // MARK: - Daily Reset
    private func autoDailyReset() {
        let today = formattedDate(Date())
        let last = UserDefaults.standard.string(forKey: storageKeyLastDailyReset)

        guard last != today else { return }

        reset(category: "daily")
        UserDefaults.standard.set(today, forKey: storageKeyLastDailyReset)
    }

    // MARK: - Weekly Reset
    private func autoWeeklyReset() {
        let week = formattedWeek(Date())
        let last = UserDefaults.standard.string(forKey: storageKeyLastWeeklyReset)

        guard last != week else { return }

        reset(category: "weekly")
        UserDefaults.standard.set(week, forKey: storageKeyLastWeeklyReset)
    }

    private func reset(category: String) {
        missions
            .filter { $0.category == category }
            .forEach {
                progress[$0.id] = 0
                completed.remove($0.id)
            }
        saveProgress()
        saveCompleted()
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private func formattedWeek(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-ww"
        return f.string(from: date)
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
