import SwiftUI

struct CodeView: View {
    let code: String

    // 🟢 Zugriff auf ThemeManager
    @EnvironmentObject private var themeManager: ThemeManager
    private var currentTheme: SlaykenTheme? { themeManager.currentTheme }
    @Environment(\.colorScheme) private var colorScheme

    // 🔹 Swift Keywords zum Highlighten
    private let keywords: [String] = [
        "import", "struct", "var", "let", "func", "return",
        "if", "else", "for", "in", "while", "class",
        "enum", "switch", "case", "default", "View", "body"
    ]

    @State private var showCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Header mit Copy-Button
            HStack {
                Text("Swift Code")
                    .font(.caption.bold())
                    .foregroundColor(currentTheme?.accent ?? .secondary)

                Spacer()

                Button(action: copyToClipboard) {
                    Label("Kopieren", systemImage: "doc.on.doc.fill")
                        .font(.caption)
                        .foregroundColor(currentTheme?.accent ?? .blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(currentTheme?.accent.opacity(0.15) ?? .blue.opacity(0.15))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // MARK: - Codeblock
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollView(.vertical, showsIndicators: true) {
                    Text(makeHighlighted(code: code))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(textColor) // 🟢 Textfarbe aus Theme
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black) // 🖤 Immer schwarzer Hintergrund
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(currentTheme?.accent.opacity(0.3) ?? .white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
        }
        .overlay(copiedOverlay, alignment: .topTrailing)
        .animation(.easeInOut(duration: 0.3), value: showCopied)
    }
}

// MARK: - Erweiterungen
private extension CodeView {

    // MARK: 🔹 Farblogik aus Theme
    var textColor: Color {
        Color(hex: currentTheme?.textHex ?? "#FFFFFF")
    }

    var accentColor: Color {
        currentTheme?.accent ?? .cyan
    }

    // MARK: 🔹 Overlay für "Kopiert"
    var copiedOverlay: some View {
        Group {
            if showCopied {
                Text("✅ Kopiert")
                    .font(.caption2.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.4), radius: 5, y: 2)
                    .transition(.scale.combined(with: .opacity))
                    .padding(.top, 6)
                    .padding(.trailing, 12)
            }
        }
    }

    // MARK: 🔹 Kopier-Logik
    func copyToClipboard() {
        UIPasteboard.general.string = code
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeOut(duration: 0.35)) { showCopied = false }
        }
    }

    // MARK: - Syntax Highlighting
    func makeHighlighted(code: String) -> AttributedString {
        var attr = AttributedString(code)

        // 🎨 Dynamisch basierend auf aktuellem Theme
        let keywordColor: Color = accentColor
        let commentColor: Color = Color(hex: currentTheme?.textHex ?? "#A8FFB5").opacity(0.7)
        let stringColor: Color = accentColor.opacity(0.9)
        let numberColor: Color = Color(hex: currentTheme?.accentHex ?? "#AA80FF")

        // 🔹 Keywords
        for keyword in keywords {
            highlight(pattern: "\\b\(keyword)\\b", color: keywordColor, bold: true, in: &attr, code: code)
        }

        // 🔹 Kommentare
        highlight(pattern: "//.*", color: commentColor, in: &attr, code: code)

        // 🔹 Strings
        highlight(pattern: "\".*?\"", color: stringColor, in: &attr, code: code)

        // 🔹 Zahlen
        highlight(pattern: "\\b[0-9]+\\b", color: numberColor, in: &attr, code: code)

        return attr
    }

    // MARK: - Regex Highlight Helper
    func highlight(pattern: String, color: Color, bold: Bool = false, in attr: inout AttributedString, code: String) {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        let nsRange = NSRange(code.startIndex..<code.endIndex, in: code)
        for match in regex.matches(in: code, range: nsRange) {
            if let swiftRange = Range(match.range, in: code),
               let range = attr.range(of: String(code[swiftRange])) {
                attr[range].foregroundColor = color
                attr[range].font = .system(.body, design: .monospaced)
                if bold {
                    attr[range].font = .system(.body, design: .monospaced).bold()
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
        var body: some View {
            Button("Drücke mich") {
                print("Button gedrückt!")
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }

    #Preview { ExampleView() }
    """)
    .environmentObject(ThemeManager())
    .preferredColorScheme(.dark)
}
