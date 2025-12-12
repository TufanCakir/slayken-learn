import SwiftUI

struct HomeView: View {

    // MARK: - UI State
    @State private var showDrawer = false

    // MARK: - Environment
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var profileManager: ProfileManager
    @EnvironmentObject private var accountManager: AccountLevelManager
    @EnvironmentObject private var missionManager: MissionManager
    @EnvironmentObject private var learningEventManager: LearningEventManager

    private var theme: SlaykenTheme? { themeManager.currentTheme }

    private func drawerWidth(_ total: CGFloat) -> CGFloat {
        min(total * 0.78, 420.0)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .leading) {

                    VStack(spacing: 0) {
                        topBar(safeAreaTop: geo.safeAreaInsets.top)
                            .padding(.top, geo.safeAreaInsets.top + 6)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                            .background(topBarBackground)
                            .zIndex(10)

                        LearningListView()
                            .disabled(showDrawer)
                            .blur(radius: showDrawer ? 6 : 0)
                            .scaleEffect(showDrawer ? 0.96 : 1)
                            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: showDrawer)
                    }

                    if showDrawer {
                        SideDrawerView(showDrawer: $showDrawer)
                            .frame(width: drawerWidth(geo.size.width))
                            .transition(.move(edge: .leading).combined(with: .opacity))
                            .shadow(color: .black.opacity(0.4), radius: 10, x: 4)
                            .zIndex(20)
                    }

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
                .background(backgroundView)
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
            .onReceive(learningEventManager.$lessonCompletedTrigger) { _ in
                missionManager.trigger(.lessonCompleted, account: accountManager)
            }
            .onChange(of: accountManager.level) { _, newLevel in
                missionManager.trigger(.levelChanged(newLevel), account: accountManager)
            }
        }
    }
}

private extension HomeView {
    func topBar(safeAreaTop: CGFloat) -> some View {
        VStack(spacing: 8) {
            AccountHeaderView()

            HStack {
                menuButton
                Spacer()
                username
                Spacer()
                missionButton
                profileButton
            }
        }
    }
}

private extension HomeView {

    var menuButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showDrawer.toggle()
            }
        } label: {
            Image(systemName: showDrawer ? "xmark" : "line.3.horizontal")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(theme?.accent ?? .white)
                .padding(10)
                .background(Circle().fill(theme?.buttonBackground ?? .black.opacity(0.4)))
        }
    }

    var username: some View {
        Text(profileManager.name.isEmpty ? "Gast" : profileManager.name)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(theme?.text ?? .white)
    }

    var missionButton: some View {
        NavigationLink {
            MissionView()
                .environmentObject(missionManager)
                .environmentObject(themeManager)
        } label: {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 24))
                .foregroundColor(theme?.accent ?? .white)
        }
    }

    var profileButton: some View {
        NavigationLink {
            ProfileView()
                .environmentObject(profileManager)
                .environmentObject(themeManager)
        } label: {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 26))
                .foregroundColor(theme?.accent ?? .white)
        }
    }
}

private extension HomeView {

    var topBarBackground: some View {
        theme?.background.view()
            .blur(radius: 15)
            .opacity(0.5)
            .overlay(Color.black.opacity(0.2))
    }

    var backgroundView: some View {
        Group {
            if let bg = theme?.background.view() {
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
    }
}


// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(ThemeManager())
        .environmentObject(ProfileManager())
        .environmentObject(AccountLevelManager())
        .environmentObject(PurchaseManager())
        .environmentObject(MissionManager())
        .environmentObject(LearningEventManager())
        .preferredColorScheme(.dark)
}

