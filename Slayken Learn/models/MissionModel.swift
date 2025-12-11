import Foundation

struct Mission: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let xpReward: Int
    let target: Int
    let category: String
}
