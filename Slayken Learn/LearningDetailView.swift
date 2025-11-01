import SwiftUI

struct LearningDetailView: View {
    let topic: LearningTopic
    
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
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews
private extension LearningDetailView {

    var headerSection: some View {
        LinearGradient(
            colors: topic.colors.backgroundColors.map { Color(hex: $0) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: isPad ? 250 : 180)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(alignment: .bottomLeading) {
            Text(topic.title)
                .font(.system(.title, design: .rounded).weight(.bold))
                .foregroundColor(Color(hex: topic.colors.textColors.first ?? currentTheme?.textHex ?? "#FFFFFF"))
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
        if !topic.description.isEmpty {
            Text(topic.description)
                .font(.body)
                .foregroundColor(currentTheme?.accent.opacity(0.8) ?? .secondary)
                .lineSpacing(4)
                .frame(maxWidth: maxContentWidth, alignment: .leading)
                .padding(.horizontal)
                .transition(.opacity)
        }
    }

    @ViewBuilder
    var stepsSection: some View {
        if !topic.steps.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Schritte")
                    .font(.headline)
                    .foregroundColor(currentTheme?.accent ?? .blue)

                ForEach(Array(topic.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(currentTheme?.accent ?? .blue)
                            .font(.system(size: 16))
                            .accessibilityHidden(true)
                        Text(step)
                            .font(.subheadline)
                            .foregroundColor(currentTheme?.accent ?? .primary)
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

            CodeView(code: topic.code)
                .frame(maxWidth: maxContentWidth)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: (currentTheme?.accent ?? .black).opacity(0.3), radius: 4, x: 0, y: 2)
                .padding(.horizontal)
        }
    }

    // MARK: - Hintergrund dynamisch
    var backgroundView: some View {
        Group {
            if let theme = currentTheme {
                theme.background.view()
            } else {
                colorScheme == .dark ? Color.black : Color.white
            }
        }
        .animation(.easeInOut(duration: 0.35), value: currentTheme?.id)
    }
}

// MARK: - Preview
#Preview {
    let example = LearningTopic(
        id: "swift_001",
        title: "Optionals verstehen",
        description: "Erfahre, wie Optionals in Swift funktionieren und wie man sie sicher entpackt.",
        icon: nil,
        steps: ["Deklariere eine optionale Variable", "Überprüfe mit if let", "Nutze optional chaining"],
        colors: .init(backgroundColors: ["#000000", "#FF6D2D", "#000000"], textColors: ["#FFFFFF"]),
        code: "var name: String? = \"Tufan\"\nif let unwrapped = name { print(unwrapped) }",
        category: "Swift",
        categoryIcon: "swift",
        categoryIconColor: "#FF6D2D"
    )

    NavigationStack {
        LearningDetailView(topic: example)
            .environmentObject(ThemeManager()) // 🟢 Wichtig!
            .preferredColorScheme(.dark)
    }
}
