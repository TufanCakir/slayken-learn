import SwiftUI

struct CodeView: View {
    let code: String

    // MARK: - Environment
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    private var currentTheme: SlaykenTheme? { themeManager.currentTheme }

    // MARK: - Keyword Sets
    private let swiftKeywords = [
        "import","struct","class","enum","protocol","extension","func",
        "var","let","return","if","else","for","in","while","guard",
        "switch","case","default","do","catch","try","await","async",
        "View","body","private","public","internal","static","final",
        "init","deinit","self","some","NavigationStack","Button",
        "Text","List","VStack","ZStack","HStack","Color"
    ]

    private let htmlTags = [
        "html","head","body","title","meta","div","span","button",
        "script","link","style","h1","h2","h3","p","a","img",
        "input","form","br","hr","ul","li"
    ]

    private let jsKeywords = [
        "import","from","export","default","function","return","const","let","var",
        "if","else","for","while","useState","useEffect","useContext","useCallback",
        "useMemo","React","View","Text","Button","StyleSheet","NavigationContainer",
        "createContext","createNativeStackNavigator"
    ]

    // MARK: - State
    @State private var showCopied = false
    @State private var attributedCode: AttributedString = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerBar

            ScrollView(.vertical, showsIndicators: true) {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(attributedCode)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(18)
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
                        .padding(.bottom, 12)
                }
            }
        }
        .overlay(copiedOverlay, alignment: .topTrailing)
        .animation(.easeInOut(duration: 0.25), value: showCopied)
        .task { await renderHighlightedCode() }
    }

    // MARK: - Header
    private var headerBar: some View {
        HStack {
            Label(languageDisplayName, systemImage: languageIcon)
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
    }
}

private extension CodeView {
    // MARK: - Farben
    var accentColor: Color { currentTheme?.accent ?? .orange }
    var commentColor: Color { Color(hex: "#7C8A99") }
    var stringColor: Color { Color(hex: "#FFD866") }
    var numberColor: Color { Color(hex: "#C792EA") }
    var keywordColor: Color { Color(hex: "#82AAFF") }
    var tagColor: Color { Color(hex: "#FF6D2D") }
    var attrColor: Color { Color(hex: "#89DDFF") }
    var operatorColor: Color { Color(hex: "#FF6D6D") }

    // MARK: - Sprache erkennen
    var detectedLanguage: String {
        let lower = code.lowercased()
        if lower.contains("<html") { return "html" }
        if lower.contains("react") || lower.contains("useeffect") || lower.contains("from 'react") {
            return "react"
        }
        return "swift"
    }

    var languageDisplayName: String {
        switch detectedLanguage {
        case "html": return "HTML Code"
        case "react": return "React Native Code"
        default: return "Swift Code"
        }
    }

    var languageIcon: String {
        switch detectedLanguage {
        case "html": return "chevron.left.forwardslash.chevron.right"
        case "react": return "atom"
        default: return "swift"
        }
    }

    // MARK: - Copy Overlay
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

    // MARK: - Kopieren
    func copyToClipboard() {
        UIPasteboard.general.string = code
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showCopied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.3)) { showCopied = false }
        }
    }

    // MARK: - Highlight Rendering
    func renderHighlightedCode() async {
        let highlighted = await makeHighlighted(code: code)
        await MainActor.run {
            withAnimation(.easeOut(duration: 0.3)) {
                self.attributedCode = highlighted
            }
        }
    }

    // MARK: - Syntax Highlighting
    func makeHighlighted(code: String) async -> AttributedString {
        var attr = AttributedString(code)

        switch detectedLanguage {
        case "html":
            highlight("(?<=<)/?\\b(" + htmlTags.joined(separator: "|") + ")\\b", color: tagColor, bold: true, in: &attr, code: code)
            highlight("\\b[a-zA-Z-]+(?==\")", color: attrColor, in: &attr, code: code)
            highlight("\".*?\"", color: stringColor, in: &attr, code: code)
            highlight("<!--.*?-->", color: commentColor, italic: true, in: &attr, code: code)

        case "react":
            highlight("\\b(" + jsKeywords.joined(separator: "|") + ")\\b", color: keywordColor, bold: true, in: &attr, code: code)
            highlight("//.*", color: commentColor, italic: true, in: &attr, code: code)
            highlight("/\\*[\\s\\S]*?\\*/", color: commentColor, italic: true, in: &attr, code: code)
            highlight("\".*?\"|'.*?'", color: stringColor, in: &attr, code: code)
            highlight("\\b[0-9]+(\\.[0-9]+)?\\b", color: numberColor, in: &attr, code: code)
            highlight("<[A-Za-z0-9_]+", color: tagColor, bold: true, in: &attr, code: code)
            highlight("[=+\\-*/<>!]+", color: operatorColor, in: &attr, code: code)

        default: // Swift
            highlight("\\b(" + swiftKeywords.joined(separator: "|") + ")\\b", color: keywordColor, bold: true, in: &attr, code: code)
            highlight("//.*", color: commentColor, italic: true, in: &attr, code: code)
            highlight("\".*?\"", color: stringColor, in: &attr, code: code)
            highlight("\\b[0-9]+(\\.[0-9]+)?\\b", color: numberColor, in: &attr, code: code)
            highlight("[=+\\-*/<>!]+", color: operatorColor, in: &attr, code: code)
        }

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
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else { return }
        let nsRange = NSRange(code.startIndex..<code.endIndex, in: code)

        regex.enumerateMatches(in: code, range: nsRange) { match, _, _ in
            guard let match = match,
                  let swiftRange = Range(match.range, in: code),
                  let range = attr.range(of: String(code[swiftRange]))
            else { return }

            attr[range].foregroundColor = color
            var font = Font.system(.body, design: .monospaced)
            if bold { font = font.bold() }
            if italic { font = font.italic() }
            attr[range].font = font
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 24) {
        // Swift
        CodeView(code: """
        import SwiftUI
        struct ExampleView: View {
            var body: some View {
                Button("Klick mich") {
                    print("Hallo Welt!") // Kommentar
                }
            }
        }
        """)

        // HTML
        CodeView(code: """
        <!DOCTYPE html>
        <html>
          <body>
            <button class="btn">Click me</button>
          </body>
        </html>
        """)

        // React Native
        CodeView(code: """
        import { useState } from 'react';
        import { View, Text, Button } from 'react-native';

        export default function Counter() {
          const [count, setCount] = useState(0);
          return (
            <View style={{ padding: 20 }}>
              <Text>Zähler: {count}</Text>
              <Button title="+1" onPress={() => setCount(count + 1)} />
            </View>
          );
        }
        """)
    }
    .environmentObject(ThemeManager())
    .preferredColorScheme(.dark)
    .padding()
}
