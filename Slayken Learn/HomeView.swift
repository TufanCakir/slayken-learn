import SwiftUI

struct HomeView: View {
    @State private var showDrawer = false

    // 🟢 Environment Objects
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var profileManager: ProfileManager
    @EnvironmentObject private var accountLevelManager: AccountLevelManager
    @EnvironmentObject private var missionManager: MissionManager
    @EnvironmentObject private var learningEventManager: LearningEventManager

    private var currentTheme: SlaykenTheme? { themeManager.currentTheme }

    // MARK: - Drawerbreite dynamisch berechnen
    private func drawerWidth(for width: CGFloat) -> CGFloat {
        min(width * 0.78, 420) // iPad fix
    }

    var body: some View {          

        NavigationStack {
            GeometryReader { proxy in
                let width = proxy.size.width

                ZStack(alignment: .leading) {
                    // MARK: - Hauptinhalt
                    VStack(spacing: 0) {
                        topBar
                            .padding(.top, safeTopInset() + 6)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                            .background(
                                currentTheme?.background.view()
                                    .blur(radius: 15)
                                    .opacity(0.5)
                                    .overlay(Color.black.opacity(0.2))
                            )
                            .shadow(color: (currentTheme?.accent ?? .white).opacity(0.2), radius: 6, y: 2)
                            .zIndex(10)

                        // 📚 Hauptinhalt
                        LearningListView()
                            .disabled(showDrawer)
                            .blur(radius: showDrawer ? 6 : 0)
                            .scaleEffect(showDrawer ? 0.96 : 1.0)
                            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: showDrawer)
                    }

                    // MARK: - Drawer
                    if showDrawer {
                        SideDrawerView(showDrawer: $showDrawer)
                            .frame(width: drawerWidth(for: width))
                            .transition(.move(edge: .leading).combined(with: .opacity))
                            .shadow(color: .black.opacity(0.4), radius: 10, x: 4, y: 0)
                            .zIndex(20)
                    }

                    // 🔲 Overlay bei geöffnetem Drawer
                    if showDrawer {
                        Color.black.opacity(0.35)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showDrawer = false
                                }
                            }
                            .zIndex(15)
                    }
                }
                .onAppear {
                    missionManager.trigger(.appOpened, account: accountLevelManager)
                }
                .onReceive(learningEventManager.$lessonCompletedTrigger) { _ in
                    missionManager.trigger(.lessonCompleted, account: accountLevelManager)
                }
                .onChange(of: accountLevelManager.level) { oldLevel, newLevel in
                    missionManager.trigger(.levelChanged(newLevel: newLevel), account: accountLevelManager)
                }
                .background(
                    Group {
                        if let bg = currentTheme?.background.view() {
                            bg
                        } else {
                            LinearGradient(
                                colors: [.black, .blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                    .ignoresSafeArea()
                )
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Unterkomponenten
private extension HomeView {
    var topBar: some View {
        VStack(spacing: 8) {
            AccountHeaderView()
                .padding(.horizontal, 20)
            // Profil Button (öffnet ProfilView)
            NavigationLink(destination: MissionView()
                .environmentObject(missionManager)
                .environmentObject(themeManager)) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 26))
                    .foregroundColor(currentTheme?.accent ?? .white)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(currentTheme?.buttonBackground ?? Color.white.opacity(0.08))
                            .shadow(color: (currentTheme?.accent ?? .white).opacity(0.25), radius: 5, y: 2)
                    )
            }
            HStack(spacing: 12) {
                // Menü Button
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showDrawer.toggle()
                    }
                } label: {
                    Image(systemName: showDrawer ? "xmark" : "line.3.horizontal")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(currentTheme?.accent ?? .white)
                        .rotationEffect(.degrees(showDrawer ? 90 : 0))
                        .padding(10)
                        .background(
                            Circle()
                                .fill(currentTheme?.buttonBackground ?? .black.opacity(0.4))
                                .overlay(
                                    Circle()
                                        .stroke((currentTheme?.accent ?? .white).opacity(0.3), lineWidth: 0.6)
                                )
                                .shadow(color: (currentTheme?.accent ?? .white).opacity(0.2), radius: 5, y: 2)
                        )
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showDrawer)
                }

                Spacer()

                // 🧑 Benutzername
                VStack(spacing: 2) {
                    Text(profileManager.name.isEmpty ? "Gast" : profileManager.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(currentTheme?.text ?? .white)
                }

                Spacer()

                // Profil Button (öffnet ProfilView)
                NavigationLink(destination: ProfileView()
                    .environmentObject(profileManager)
                    .environmentObject(themeManager)) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(currentTheme?.accent ?? .white)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(currentTheme?.buttonBackground ?? Color.white.opacity(0.08))
                                .shadow(color: (currentTheme?.accent ?? .white).opacity(0.25), radius: 5, y: 2)
                        )
                }
            }
        }
    }

    // MARK: - Safe Area Helper
    func safeTopInset() -> CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.safeAreaInsets.top }
            .first ?? 0
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(ThemeManager())
        .environmentObject(ProfileManager())
        .environmentObject(AccountLevelManager())
        .environmentObject(MissionManager())
        .environmentObject(LearningEventManager())
        .preferredColorScheme(.dark)
}

