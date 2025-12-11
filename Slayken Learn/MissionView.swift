import SwiftUI

struct MissionView: View {

    @EnvironmentObject private var missionManager: MissionManager
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var accountLevel: AccountLevelManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                Text("Missionen")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(themeManager.currentTheme?.accent ?? .blue)

                ForEach(missionManager.missions) { mission in
                    missionCard(mission)
                }
            }
            .padding()
        }
        .background(
            themeManager.currentTheme?.background.view()
                .ignoresSafeArea()
        )
    }

    // MARK: - Mission Card UI
    @ViewBuilder
    func missionCard(_ mission: Mission) -> some View {

        let current = missionManager.progress[mission.id] ?? 0
        let finished = missionManager.completed.contains(mission.id)

        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(mission.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if finished {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 22))
                }
            }

            Text(mission.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))

            ProgressView(value: Double(current) / Double(mission.target))
                .tint(themeManager.currentTheme?.accent ?? .blue)

            HStack {
                Text("\(current)/\(mission.target)")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.caption)

                Spacer()

                Text("+\(mission.xpReward) XP")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.25), radius: 10)
        )
    }
}
