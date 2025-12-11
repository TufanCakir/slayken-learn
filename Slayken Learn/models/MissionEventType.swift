import Foundation

enum MissionEventType {
    case appOpened
    case lessonCompleted
    case levelChanged(newLevel: Int)
}
