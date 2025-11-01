import SwiftUI

struct DrawerDetailView: View {
    let section: DrawerSection

    // 🟢 Zugriff auf ThemeManager
    @EnvironmentObject private var themeManager: ThemeManager
    private var currentTheme: SlaykenTheme? { themeManager.currentTheme }

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Layout
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    private var maxContentWidth: CGFloat {
        isPad ? 640 : .infinity
    }

    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                descriptionSection
                stepsSection
                codeSection
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(backgroundView.ignoresSafeArea())
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews
private extension DrawerDetailView {

    var headerSection: some View {
        LinearGradient(
            colors: section.colors.backgroundColors.map { Color(hex: $0) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: isPad ? 250 : 180)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(alignment: .bottomLeading) {
            Text(section.title)
                .font(.system(.title, design: .rounded).weight(.bold))
                .foregroundColor(Color(hex: section.colors.textColors.first ?? currentTheme?.textHex ?? "#FFFFFF"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .shadow(radius: 4)
                .padding()
        }
        .padding(.horizontal)
        .shadow(color: (currentTheme?.accent ?? .black).opacity(0.4), radius: 5, x: 0, y: 3)
        .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    var descriptionSection: some View {
        if !section.description.isEmpty {
            Text(section.description)
                .font(.body)
                .foregroundColor(currentTheme?.text.opacity(0.8) ?? .secondary)
                .lineSpacing(4)
                .frame(maxWidth: maxContentWidth, alignment: .leading)
                .padding(.horizontal)
                .transition(.opacity)
        }
    }

    @ViewBuilder
    var stepsSection: some View {
        if !section.steps.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Schritte")
                    .font(.headline)
                    .foregroundColor(currentTheme?.accent ?? .blue)

                ForEach(Array(section.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(currentTheme?.accent ?? .blue)
                            .font(.system(size: 16))
                            .accessibilityHidden(true)
                        Text(step)
                            .font(.subheadline)
                            .foregroundColor(currentTheme?.text ?? .primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityLabel("Schritt \(index + 1): \(step)")
                    }
                }
            }
            .frame(maxWidth: maxContentWidth, alignment: .leading)
            .padding(.horizontal)
        }
    }

    var codeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Code-Beispiel")
                .font(.headline)
                .foregroundColor(currentTheme?.accent ?? .blue)
                .padding(.horizontal)

            CodeView(code: section.code)
                .frame(maxWidth: maxContentWidth)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: (currentTheme?.accent ?? .black).opacity(0.3), radius: 4, x: 0, y: 2)
                .padding(.horizontal)
        }
    }

    // MARK: - Hintergrund
    var backgroundView: some View {
        Group {
            if let theme = currentTheme {
                theme.background.view()
            } else {
                (colorScheme == .dark ? Color.black : Color.white)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: currentTheme?.id)
    }
}

// MARK: - Preview
#Preview {
    let example = DrawerSection(
        id: "swift_001",
        title: "Button Erstellen",
        description: "Erfahre, wie man in SwiftUI einen einfachen Button mit Aktion erstellt.",
        icon: "🔥",
        steps: ["Button mit Label erstellen", "Aktion mit Closure definieren", "Design mit Modifiers anpassen"],
        colors: DrawerColor(backgroundColors: ["#000000", "#FF6D2D", "#000000"], textColors: ["#FFFFFF"]),
        code: """
        import SwiftUI

        struct ButtonExampleView: View {
            var body: some View {
                Button(action: {
                    print("Button gedrückt!")
                }) {
                    Text("Drücke mich")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }

        #Preview { ButtonExampleView() }
        """,
        category: "SwiftUI",
        categoryIcon: "swift",
        categoryIconColor: "#FF6D2D"
    )

    NavigationStack {
        DrawerDetailView(section: example)
            .environmentObject(ThemeManager()) // 🟢 Wichtig für Theme-Vorschau
            .preferredColorScheme(.dark)
    }
}
