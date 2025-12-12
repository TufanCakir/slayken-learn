import Foundation

enum MissionEventType {
    case appOpened
    case lessonCompleted
    case lessonRepeated
    case lessonShared
    case categoryOpened
    case learningMinutes(Int)
    case xpGained(Int)
    case levelChanged(Int)
}
