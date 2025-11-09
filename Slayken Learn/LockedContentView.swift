import SwiftUI

struct LockedContentView: View {
    let topic: LearningTopic
    @EnvironmentObject private var themeManager: ThemeManager
    private var currentTheme: SlaykenTheme? { themeManager.currentTheme }

    // MARK: - Body
    var body: some View {
        ZStack {
            // 🌌 Hintergrund
            if let theme = currentTheme {
                theme.fullBackgroundView()
                    .overlay(Color.black.opacity(0.35))
                    .ignoresSafeArea()
            } else {
                LinearGradient(colors: [.black, .blue.opacity(0.9)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            }

            // 🧱 Inhalt
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 64, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(colors: [.yellow, .orange],
                                           startPoint: .top,
                                           endPoint: .bottom)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
                        .symbolEffect(.bounce, options: .repeat(2), value: true)

                    Text("Gesperrt")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .transition(.opacity.combined(with: .scale))
                    
                    Text("„\(topic.title)“ ist aktuell gesperrt.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 20)

                    Text("Kaufe diesen Code im Slayken Code-Shop, um ihn freizuschalten.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 32)
                }

                // 🛒 Button zum Code-Shop
                NavigationLink(
                    destination: SlaykenCodeShopView(preselectedProductID: topic.productID)
                ) {
                    Label("Zum Code-Shop", systemImage: "cart.fill.badge.plus")
                        .font(.headline)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [
                                currentTheme?.accent ?? .blue,
                                (currentTheme?.accent ?? .blue).opacity(0.8)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.4), radius: 6, y: 4)
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)

                .padding(.top, 8)

                Spacer(minLength: 0)
            }
            .padding()
            .frame(maxWidth: 600)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
        .animation(.easeInOut(duration: 0.35), value: currentTheme?.id)
    }
}
