import SwiftUI

struct AccountHeaderView: View {
    @EnvironmentObject var accountManager: AccountLevelManager
    @EnvironmentObject var themeManager: ThemeManager

    @State private var pulse = false

    private var accent: Color {
        themeManager.currentTheme?.accent ?? .blue
    }

    var body: some View {
        VStack(spacing: 10) {

            // LEVEL
            Text("Level \(accountManager.level)")
                .font(.system(size: 30, weight: .heavy))
                .foregroundColor(accent)
                .shadow(color: accent.opacity(0.6), radius: 8)
                .scaleEffect(pulse ? 1.04 : 1.0)
                .animation(.easeInOut(duration: 1.6).repeatForever(), value: pulse)

            // XP PROGRESS
            ProgressView(value: accountManager.progress)
                .tint(accent)
                .frame(height: 8)
                .padding(.horizontal, 30)
                .clipShape(Capsule())
                .shadow(color: accent.opacity(0.4), radius: 8)

            // XP TEXT
            Text("\(accountManager.xp) / \(accountManager.nextLevelXP) XP")
                .font(.caption)
                .foregroundColor(.white.opacity(0.75))
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: accent.opacity(0.25), radius: 12, y: 4)
        )
        .padding(.horizontal, 12)
        .onAppear {
            pulse = true
        }
    }
}
