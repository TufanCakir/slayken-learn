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
        id: "swiftProduct_001",
        title: "SwiftUI Calculator Code",
        description: "Erfahre, wie Optionals in Swift funktionieren und wie man sie sicher entpackt.",
        icon: nil,
        steps: ["Deklariere eine optionale Variable", "Überprüfe mit if let", "Nutze optional chaining"],
        colors: .init(backgroundColors: ["#000000", "#0A84FF", "#000000"], textColors: ["#FFFFFF"]),
        code: "//  CodePreviewView.swift\n//  Slayken Learn\n//\n//  Created by Tufan Cakir on 04.11.25.\n\nimport SwiftUI\n\nstruct CodePreviewView: View {\n    @State private var display: String = \"0\"\n    @State private var lastOperator: String? = nil\n    @State private var lastValue: Double? = nil\n    @State private var isEnteringNewNumber = false\n\n    private let buttons = [\n        [\"AC\", \"+/-\", \"%\", \"÷\"],\n        [\"7\", \"8\", \"9\", \"×\"],\n        [\"4\", \"5\", \"6\", \"−\"],\n        [\"1\", \"2\", \"3\", \"+\"],\n        [\"0\", \".\", \"=\"]\n    ]\n\n    var body: some View {\n        ZStack {\n            LinearGradient(colors: [.black, Color.blue.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)\n                .ignoresSafeArea()\n\n            VStack(spacing: 18) {\n                Spacer()\n                HStack {\n                    Spacer()\n                    Text(display)\n                        .font(.system(size: 68, weight: .semibold, design: .rounded))\n                        .foregroundColor(.white)\n                        .lineLimit(1)\n                        .minimumScaleFactor(0.5)\n                        .padding()\n                        .frame(maxWidth: .infinity, alignment: .trailing)\n                }\n                .background(Color.white.opacity(0.05))\n                .cornerRadius(16)\n                .shadow(color: .black.opacity(0.4), radius: 10, y: 5)\n                .padding(.horizontal)\n\n                VStack(spacing: 12) {\n                    ForEach(buttons, id: \\.self) { row in\n                        HStack(spacing: 12) {\n                            ForEach(row, id: \\.self) { symbol in\n                                Button(action: { buttonTapped(symbol) }) {\n                                    Text(symbol)\n                                        .font(.system(size: 28, weight: .semibold, design: .rounded))\n                                        .frame(maxWidth: .infinity, minHeight: 70)\n                                        .background(buttonColor(for: symbol))\n                                        .foregroundColor(.white)\n                                        .cornerRadius(40)\n                                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)\n                                }\n                                .buttonStyle(ScaleButtonStyle())\n                            }\n                        }\n                    }\n                }\n                .padding(.horizontal)\n                .padding(.bottom, 20)\n            }\n        }\n    }\n\n    private func buttonTapped(_ symbol: String) {\n        switch symbol {\n        case \"AC\": clear()\n        case \"+/-\": toggleSign()\n        case \"%\": applyPercent()\n        case \"÷\", \"×\", \"−\", \"+\": setOperator(symbol)\n        case \"=\": calculateResult()\n        default: enterNumber(symbol)\n        }\n    }\n\n    private func clear() {\n        display = \"0\"\n        lastOperator = nil\n        lastValue = nil\n        isEnteringNewNumber = false\n    }\n\n    private func toggleSign() {\n        guard var value = Double(display) else { return }\n        value *= -1\n        display = String(format: \"%.2f\", value)\n    }\n\n    private func applyPercent() {\n        guard var value = Double(display) else { return }\n        value /= 100\n        display = String(format: \"%.2f\", value)\n    }\n\n    private func setOperator(_ op: String) {\n        lastValue = Double(display)\n        lastOperator = op\n        isEnteringNewNumber = true\n    }\n\n    private func calculateResult() {\n        guard let lastVal = lastValue, let op = lastOperator, let currentVal = Double(display) else { return }\n        var result: Double = 0\n        switch op {\n        case \"+\": result = lastVal + currentVal\n        case \"−\": result = lastVal - currentVal\n        case \"×\": result = lastVal * currentVal\n        case \"÷\": result = currentVal != 0 ? lastVal / currentVal : 0\n        default: break\n        }\n        display = String(format: \"%g\", result)\n        lastOperator = nil\n        lastValue = nil\n    }\n\n    private func enterNumber(_ symbol: String) {\n        if isEnteringNewNumber {\n            display = (symbol == \".\") ? \"0.\" : symbol\n            isEnteringNewNumber = false\n        } else {\n            if display == \"0\" && symbol != \".\" {\n                display = symbol\n            } else {\n                display += symbol\n            }\n        }\n    }\n\n    private func buttonColor(for symbol: String) -> Color {\n        switch symbol {\n        case \"AC\", \"+/-\", \"%\": return Color.gray.opacity(0.5)\n        case \"÷\", \"×\", \"−\", \"+\", \"=\": return Color.blue\n        default: return Color.gray.opacity(0.25)\n        }\n    }\n}\n\nstruct ScaleButtonStyle: ButtonStyle {\n    func makeBody(configuration: Configuration) -> some View {\n        configuration.label\n            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)\n            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)\n    }\n}\n\n#Preview {\n    CodePreviewView()\n        .preferredColorScheme(.dark)\n}",
        category: "Calculator Template",
        categoryIcon: "swift",
        categoryIconColor: "#FF6D2D",
        productID: "swift_calculator"

    )

    NavigationStack {
        LearningDetailView(topic: example)
            .environmentObject(ThemeManager()) // 🟢 Wichtig!
            .preferredColorScheme(.dark)
    }
}
