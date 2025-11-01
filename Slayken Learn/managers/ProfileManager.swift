import SwiftUI
import Combine

final class ProfileManager: ObservableObject {
    // MARK: - Persistent Data
    @AppStorage("userName") private var storedName: String = ""

    // MARK: - Published
    @Published var name: String = ""

    // MARK: - Init
    init() {
        name = storedName
    }

    // MARK: - Funktionen
    func saveProfile() {
        storedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func resetProfile() {
        name = ""
        storedName = ""
    }
}
