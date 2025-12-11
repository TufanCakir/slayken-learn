import Foundation
import SwiftUI
internal import Combine

@MainActor
final class AccountLevelManager: ObservableObject {

    // MARK: - Published Werte
    @Published private(set) var level: Int
    @Published private(set) var xp: Int
    @Published private(set) var nextLevelXP: Int

    // MARK: - Init + Laden
    init() {
        // Falls keine Werte gespeichert sind → Default
        let savedLevel = UserDefaults.standard.integer(forKey: "account_level")
        let savedXP = UserDefaults.standard.integer(forKey: "account_xp")

        let initialLevel = max(savedLevel, 1)
        let initialXP = max(savedXP, 0)
        self.level = initialLevel
        self.xp = initialXP
        self.nextLevelXP = AccountLevelManager.xpRequirement(for: initialLevel)
    }

    // MARK: - XP Formel (Blizzard Style)
    static func xpRequirement(for level: Int) -> Int {
        // Beispiel: jede Stufe +20% mehr
        return Int(100 * pow(1.20, Double(level - 1)))
    }

    // MARK: - XP hinzufügen
    func addXP(_ amount: Int) {
        xp += amount
        save()

        while xp >= nextLevelXP {
            xp -= nextLevelXP
            levelUp()
        }
    }

 
    var onLevelChanged: ((Int) -> Void)?

    private func levelUp() {
        level += 1
        nextLevelXP = AccountLevelManager.xpRequirement(for: level)
        save()

        onLevelChanged?(level)
    }


    // MARK: - XP Progress (für ProgressBars)
    var progress: Double {
        Double(xp) / Double(nextLevelXP)
    }

    // MARK: - Reset (falls du im SettingsView Reset willst)
    func reset() {
        level = 1
        xp = 0
        nextLevelXP = AccountLevelManager.xpRequirement(for: level)
        save()
    }

    // MARK: - Speichern in UserDefaults
    private func save() {
        UserDefaults.standard.set(level, forKey: "account_level")
        UserDefaults.standard.set(xp, forKey: "account_xp")
    }
}
