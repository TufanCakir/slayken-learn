import SwiftUI

struct OnboardingView: View {

    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var profileManager: ProfileManager

    @State private var pageIndex = 0
    @Binding var showOnboarding: Bool

    private var currentTheme: SlaykenTheme? { themeManager.currentTheme }

    var body: some View {
        ZStack {
            // Background
            Group {
                if let bg = currentTheme?.background.view() {
                    bg
                } else {
                    Color.black
                }
            }
            .ignoresSafeArea()

            VStack {
                TabView(selection: $pageIndex) {

                    OnboardPage(
                        image: "sparkles",
                        title: "Willkommen bei Slayken Lernen",
                        subtitle: "Lerne Swift, SwiftUI, und vieles mehr– alles in einem epischen Flow."
                    )
                    .tag(0)

                    OnboardPage(
                        image: "books.vertical.fill",
                        title: "Interaktive Lernmodule",
                        subtitle: "Kurze Lektionen, schöne UI, klare Erklärungen. Perfekt für jeden Tag."
                    )
                    .tag(1)

                    OnboardPage(
                        image: "bolt.fill",
                        title: "Dein persönlicher Fortschritt",
                        subtitle: "Verdiene XP, schalte Themen frei und meistere deinen eigenen Lernpfad."
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .animation(.easeInOut, value: pageIndex)

                Spacer()

                // MARK: - Weiter / Los geht's Button
                Button(action: {
                    if pageIndex < 2 {
                        withAnimation(.easeInOut) {
                            pageIndex += 1
                        }
                    } else {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showOnboarding = false
                        }
                    }
                }) {
                    Text(pageIndex < 2 ? "Weiter" : "Los geht’s!")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 40)
                        .background(
                            (currentTheme?.accent ?? .white)
                                .clipShape(Capsule())
                                .shadow(color: (currentTheme?.accent ?? .white).opacity(0.4), radius: 8, y: 4)
                        )
                }
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct OnboardPage: View {
    let image: String
    let title: String
    let subtitle: String

    @EnvironmentObject private var themeManager: ThemeManager
    private var currentTheme: SlaykenTheme? { themeManager.currentTheme }

    @State private var fadeIn = false
    @State private var slideUp = false

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            Image(systemName: image)
                .font(.system(size: 70))
                .foregroundColor(currentTheme?.accent ?? .white)
                .opacity(fadeIn ? 1 : 0)
                .scaleEffect(fadeIn ? 1 : 0.6)
                .animation(.spring(response: 0.7, dampingFraction: 0.7), value: fadeIn)

            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(currentTheme?.text ?? .white)

                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor((currentTheme?.text ?? .white).opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            .offset(y: slideUp ? 0 : 40)
            .opacity(slideUp ? 1 : 0)
            .animation(.easeOut(duration: 0.7), value: slideUp)

            Spacer()
        }
        .onAppear {
            fadeIn = true
            slideUp = true
        }
    }
}
 
