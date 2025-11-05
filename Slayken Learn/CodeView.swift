import SwiftUI

struct CodeView: View {
    let code: String

    // 🧩 Theme
    @EnvironmentObject private var themeManager: ThemeManager
    private var currentTheme: SlaykenTheme? { themeManager.currentTheme }
    @Environment(\.colorScheme) private var colorScheme

    // 🟣 Swift Keywords
    private let keywords = [
        "import", "struct", "class", "enum", "protocol", "extension", "func",
        "var", "let", "return", "if", "else", "for", "in", "while", "guard",
        "switch", "case", "default", "do", "catch", "try", "await", "async",
        "View", "body", "private", "public", "internal", "static", "final",
        "init", "deinit", "self", "some", "NavigationStack", "Button",
        "Text", "List", "VStack", "ZStack", "HStack", "Color"
    ]

    @State private var showCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Header mit Copy-Button
            HStack {
                Label("Swift Code", systemImage: "swift")
                    .font(.caption.bold())
                    .foregroundStyle(accentColor)

                Spacer()

                Button(action: copyToClipboard) {
                    Label("Kopieren", systemImage: "doc.on.doc.fill")
                        .font(.caption2.bold())
                        .foregroundColor(accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(accentColor.opacity(0.15))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // MARK: - Codeblock
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollView(.vertical, showsIndicators: true) {
                    Text(makeHighlighted(code: code))
                        .font(.system(.body, design: .monospaced))
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            LinearGradient(
                                colors: [Color.black, Color(hex: "#1C1C1E")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(accentColor.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                }
            }
        }
        .overlay(copiedOverlay, alignment: .topTrailing)
        .animation(.easeInOut(duration: 0.25), value: showCopied)
    }
}

// MARK: - Erweiterungen
private extension CodeView {
    // MARK: - Farben
    var accentColor: Color { currentTheme?.accent ?? .blue }
    var textColor: Color { Color(hex: currentTheme?.textHex ?? "#FFFFFF") }
    var commentColor: Color { Color(hex: "#6C757D") }
    var stringColor: Color { Color(hex: "#F5D547") }
    var typeColor: Color { Color(hex: "#42A5F5") }
    var numberColor: Color { Color(hex: "#D48FFF") }
    var operatorColor: Color { Color(hex: "#FF6D6D") }

    // MARK: - Copy Feedback
    var copiedOverlay: some View {
        Group {
            if showCopied {
                Label("Kopiert", systemImage: "checkmark.circle.fill")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
                    .transition(.scale.combined(with: .opacity))
                    .padding(.top, 8)
                    .padding(.trailing, 12)
            }
        }
    }

    func copyToClipboard() {
        UIPasteboard.general.string = code
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.3)) { showCopied = false }
        }
    }

    // MARK: - Syntax-Highlighting
    func makeHighlighted(code: String) -> AttributedString {
        var attr = AttributedString(code)

        highlight("\\b(" + keywords.joined(separator: "|") + ")\\b", color: accentColor, bold: true, in: &attr, code: code)
        highlight("//.*", color: commentColor, italic: true, in: &attr, code: code)               // Kommentare
        highlight("\".*?\"", color: stringColor, in: &attr, code: code)                           // Strings
        highlight("\\b[0-9]+(\\.[0-9]+)?\\b", color: numberColor, in: &attr, code: code)          // Zahlen
        highlight("\\b[A-Z][A-Za-z0-9_]+\\b", color: typeColor, in: &attr, code: code)            // Typen
        highlight("[=+\\-*/<>!]+", color: operatorColor, in: &attr, code: code)                   // Operatoren
        highlight("[(){}]", color: accentColor.opacity(0.8), in: &attr, code: code)               // Klammern

        return attr
    }

    // MARK: - Regex Helper
    func highlight(_ pattern: String,
                   color: Color,
                   bold: Bool = false,
                   italic: Bool = false,
                   in attr: inout AttributedString,
                   code: String)
    {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        let nsRange = NSRange(code.startIndex..<code.endIndex, in: code)

        for match in regex.matches(in: code, range: nsRange) {
            if let swiftRange = Range(match.range, in: code),
               let range = attr.range(of: String(code[swiftRange])) {
                attr[range].foregroundColor = color
                if bold {
                    attr[range].font = .system(.body, design: .monospaced).bold()
                } else if italic {
                    attr[range].font = .system(.body, design: .monospaced).italic()
                } else {
                    attr[range].font = .system(.body, design: .monospaced)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CodeView(code: """
    import SwiftUI

    struct ExampleView: View {
        @State private var count = 0

        var body: some View {
            VStack {
                Text("Zähler: \\(count)")
                    .font(.title2)
                    .padding()

                Button("Erhöhen") {
                    count += 1 // erhöht den Wert
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }

    #Preview { ExampleView() }
    """)
    .environmentObject(ThemeManager())
    .preferredColorScheme(.dark)
}
