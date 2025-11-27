import SwiftUI

struct CodeView: View {
    let code: String

    // MARK: - Environment
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    private var currentTheme: SlaykenTheme? { themeManager.currentTheme }

    // MARK: - Keywords
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
    @State private var attributedCode: AttributedString = AttributedString("")

    // MARK: - View
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
                        .background(backgroundGradient)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(accentColor.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
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
                    .background(RoundedRectangle(cornerRadius: 6).fill(accentColor.opacity(0.15)))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Extension
private extension CodeView {
    // MARK: - Farben
    var accentColor: Color { currentTheme?.accent ?? .orange }
    var commentColor: Color { Color(hex: "#8E8E93") }
    var stringColor: Color { Color(hex: "#FFD866") }
    var numberColor: Color { Color(hex: "#C792EA") }
    var keywordColor: Color { Color(hex: "#82AAFF") }
    var tagColor: Color { Color(hex: "#FF6D2D") }
    var attrColor: Color { Color(hex: "#89DDFF") }
    var operatorColor: Color { Color(hex: "#FF6D6D") }

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color.black, Color(hex: "#1C1C1E")]
                : [Color(hex: "#F2F2F7"), Color(hex: "#E5E5EA")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

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
        case "html": return "HTML"
        case "react": return "React Native"
        default: return "Swift"
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

    // MARK: - Copy
    func copyToClipboard() {
        UIPasteboard.general.string = code
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.3)) { showCopied = false }
        }
    }

    // MARK: - Highlight Pipeline
    func renderHighlightedCode() async {
        let highlighted = await makeHighlighted(code: code)
        await MainActor.run {
            withAnimation(.easeOut(duration: 0.3)) {
                self.attributedCode = highlighted
            }
        }
    }

    func makeHighlighted(code: String) async -> AttributedString {
        var attr = AttributedString(code)
        switch detectedLanguage {
        case "html":
            applyHighlights([
                ("(?<=<)/?\\b(" + htmlTags.joined(separator: "|") + ")\\b", tagColor, true, false),
                ("\\b[a-zA-Z-]+(?==\")", attrColor, false, false),
                ("\".*?\"", stringColor, false, false),
                ("<!--[\\s\\S]*?-->", commentColor, false, true)
            ], to: &attr, code: code)

        case "react":
            applyHighlights([
                ("\\b(" + jsKeywords.joined(separator: "|") + ")\\b", keywordColor, true, false),
                // Line Comments
                ("//[^\n]*", commentColor, false, true),
                // Block Comments
                ("/\\*[\\s\\S]*?\\*/", commentColor, false, true),
                // TODO, FIXME
                ("\\/\\/\\s*(TODO|FIXME|NOTE):?[^\n]*", commentColor, true, true),
                ("\".*?\"|'.*?'", stringColor, false, false),
                ("\\b[0-9]+(\\.[0-9]+)?\\b", numberColor, false, false),
                ("<[A-Za-z0-9_]+", tagColor, true, false),
                ("[=+\\-*/<>!]+", operatorColor, false, false)
            ], to: &attr, code: code)

        default: // Swift
            applyHighlights([
                ("(?m)^\\s*//\\s*(MARK:|- MARK:|MARK -).*", commentColor, true, true),
                // Keywords
                ("\\b(" + swiftKeywords.joined(separator: "|") + ")\\b", keywordColor, true, false),

                // MARK, TODO, NOTE, FIXME
                ("//\\s*(MARK:|- MARK:|MARK -)[^\n]*", commentColor, true, false),
                ("//\\s*(TODO|FIXME|NOTE):?[^\n]*", commentColor, true, true),

                // Normal comments
                ("//.*", commentColor, false, true),

                // Multiline comments
                ("/\\*[\\s\\S]*?\\*/", commentColor, false, true),

                // Strings
                ("\".*?\"", stringColor, false, false),

                // Numbers
                ("\\b[0-9]+(\\.[0-9]+)?\\b", numberColor, false, false),

                // Operators
                ("[=+\\-*/<>!]+", operatorColor, false, false)
            ], to: &attr, code: code)

        }
        return attr
    }

    func applyHighlights(_ rules: [(String, Color, Bool, Bool)],
                         to attr: inout AttributedString,
                         code: String) {
        for (pattern, color, bold, italic) in rules {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else { continue }
            let nsRange = NSRange(code.startIndex..<code.endIndex, in: code)

            regex.enumerateMatches(in: code, range: nsRange) { match, _, _ in
                guard let match = match,
                      let range = Range(match.range, in: code),
                      let lower = AttributedString.Index(range.lowerBound, within: attr),
                      let upper = AttributedString.Index(range.upperBound, within: attr)
                else { return }

                let attributedRange = lower..<upper
                attr[attributedRange].foregroundColor = color

                var font = Font.system(.body, design: .monospaced)
                if bold { font = font.bold() }
                if italic { font = font.italic() }
                attr[attributedRange].font = font
            }
        }
    }

}

// MARK: - Preview
#Preview {
    VStack(spacing: 24) {
        CodeView(code: """
        import SwiftUI\n\nstruct pnstruct Product: Identifiable, Hashable {\n    let id = UUID()\n    let name: String\n    let price: Double\n    let icon: String\n}\n\n/MARK: - Main View\nstruct ECommerceDemoView: View {\n    @State private var products: [Product] = [\n        Product(name: \"SwiftUI Template\", price: 19.99, icon: \"🧩\"),\n        Product(name: \"Pro UI Kit\", price: 14.99, icon: \"🎨\"),\n        Product(name: \"JSON Helper Tool\", price: 9.99, icon: \"💾\"),\n        Product(name: \"Metal Shader Pack\", price: 12.99, icon: \"💠\"),\n        Product(name: \"Game Asset Bundle\", price: 7.49, icon: \"🎮\"),\n        Product(name: \"Font Collection\", price: 4.99, icon: \"🔤\")\n    ]\n    \n    @State private var cart: [Product: Int] = [:]\n    @State private var showCart = false\n    \n    private var cartCount: Int { cart.values.reduce(0, +) }\n    private var cartTotal: Double {\n        cart.reduce(0) { $0 + Double($1.value) * $1.key.price }\n    }\n    \n    private let columns = [GridItem(.flexible()), GridItem(.flexible())]\n    \n    var body: some View {\n        ScrollView {\n            LazyVGrid(columns: columns, spacing: 16) {\n                ForEach(products) { product in\n                    ProductCard(product: product) {\n                        add(product)\n                    }\n                }\n            }\n            .padding()\n        }\n        .navigationTitle(\"🛍️ Demo-Shop\")\n        .toolbar {\n            ToolbarItem(placement: .topBarTrailing) {\n                Button {\n                    showCart = true\n                } label: {\n                    HStack(spacing: 4) {\n                        Image(systemName: \"cart.fill\")\n                        if cartCount > 0 {\n                            Text(\"\\(cartCount)\")\n                                .font(.footnote.bold())\n                                .padding(4)\n                                .background(Capsule().fill(Color.blue.opacity(0.15)))\n                        }\n                    }\n                }\n                .accessibilityLabel(\"Warenkorb öffnen\")\n            }\n        }\n        .sheet(isPresented: $showCart) {\n            NavigationStack {\n                CartView(\n                    cart: cart,\n                    onIncrement: { add($0) },\n                    onDecrement: { decrement($0) },\n                    onRemove: { remove($0) },\n                    total: cartTotal\n                )\n                .navigationTitle(\"Warenkorb\")\n                .toolbar {\n                    ToolbarItem(placement: .topBarTrailing) {\n                        Button(\"Fertig\") { showCart = false }\n                    }\n                }\n            }\n        }\n    }\n    \n / MARK: - Cart Logic\n    private func add(_ product: Product) {\n        cart[product, default: 0] += 1\n    }\n    \n    private func decrement(_ product: Product) {\n        guard let qty = cart[product] else { return }\n        if qty <= 1 {\n            cart.removeValue(forKey: product)\n        } else {\n            cart[product] = qty - 1\n        }\n    }\n    \n    private func remove(_ product: Product) {\n        cart.removeValue(forKey: product)\n    }\n}\n\n/ MARK: - Product Card\nstruct ProductCard: View {\n    let product: Product\n    let addAction: () -> Void\n    \n    var body: some View {\n        VStack(spacing: 8) {\n            Text(product.icon)\n                .font(.system(size: 40))\n                .frame(maxWidth: .infinity, minHeight: 80)\n                .background(.thinMaterial)\n                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))\n            \n            VStack(alignment: .leading, spacing: 4) {\n                Text(product.name)\n                    .font(.headline)\n                Text(product.price, format: .currency(code: Locale.current.currency?.identifier ?? \"USD\"))\n                    .font(.subheadline)\n                    .foregroundStyle(.secondary)\n            }\n            \n            HStack {\n                Spacer()\n                Button(action: addAction) {\n                    Label(\"Hinzufügen\", systemImage: \"plus.circle.fill\")\n                }\n                .buttonStyle(.borderedProminent)\n            }\n        }\n        .padding()\n        .background(\n            RoundedRectangle(cornerRadius: 16, style: .continuous)\n                .fill(Color(.systemBackground))\n                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)\n        )\n    }\n}\n\n/ MARK: - Cart View\nstruct CartView: View {\n    let cart: [Product: Int]\n    let onIncrement: (Product) -> Void\n    let onDecrement: (Product) -> Void\n    let onRemove: (Product) -> Void\n    let total: Double\n    \n    private var items: [(product: Product, qty: Int)] {\n        cart.map { ($0.key, $0.value) }.sorted { $0.product.name < $1.product.name }\n    }\n    \n    var body: some View {\n        List {\n            ForEach(items, id: \\.product) { item in\n                HStack(spacing: 12) {\n                    Text(item.product.icon)\n                        .font(.largeTitle)\n                    \n                    VStack(alignment: .leading) {\n                        Text(item.product.name)\n                            .font(.headline)\n                        Text(item.product.price, format: .currency(code: Locale.current.currency?.identifier ?? \"USD\"))\n                            .foregroundStyle(.secondary)\n                    }\n                    \n                    Spacer()\n                    \n                    HStack(spacing: 8) {\n                        Button(action: { onDecrement(item.product) }) {\n                            Image(systemName: \"minus.circle.fill\").font(.title3)\n                        }\n                        Text(\"\\(item.qty)\")\n                            .frame(minWidth: 24)\n                        Button(action: { onIncrement(item.product) }) {\n                            Image(systemName: \"plus.circle.fill\").font(.title3)\n                        }\n                    }\n                    \n                    Button(role: .destructive, action: { onRemove(item.product) }) {\n                        Image(systemName: \"trash\")\n                    }\n                }\n                .buttonStyle(.plain)\n            }\n            \n            if items.isEmpty {\n                ContentUnavailableView(\n                    \"Warenkorb ist leer\",\n                    systemImage: \"cart\",\n                    description: Text(\"Füge Demo-Produkte hinzu, um die Funktion zu testen.\")\n                )\n            }\n            \n            Section {\n                HStack {\n                    Text(\"Gesamtsumme\")\n                    Spacer()\n                    Text(total, format: .currency(code: Locale.current.currency?.identifier ?? \"USD\")).bold()\n                }\n                Button {\n                    / Demo Checkout — keine echten Zahlungen\n                } label: {\n                    Label(\"Zur Kasse (Demo)\", systemImage: \"creditcard.fill\")\n                }\n                .buttonStyle(.borderedProminent)\n                .disabled(items.isEmpty)\n            }\n        }\n    }\n}\n\n/ MARK: - Preview\n#Preview {\n    NavigationStack {\n        ECommerceDemoView()\n
    
""")
    }
    .environmentObject(ThemeManager())
    .preferredColorScheme(.dark)
    .padding()
}
