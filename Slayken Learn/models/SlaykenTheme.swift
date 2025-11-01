import SwiftUI

// MARK: - Hintergrundtyp (solid, linear, radial, image)
enum ThemeBackground: Codable, Equatable {
    case solid(String)
    case linear([String])
    case radial([String])
    case image(String)

    private enum CodingKeys: String, CodingKey {
        case type, colors, image
    }

    // MARK: - Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = (try? container.decode(String.self, forKey: .type))?.lowercased() ?? "solid"

        switch type {
        case "linear":
            let colors = try container.decode([String].self, forKey: .colors)
            self = .linear(colors)
        case "radial":
            let colors = try container.decode([String].self, forKey: .colors)
            self = .radial(colors)
        case "image":
            let name = (try? container.decode(String.self, forKey: .image)) ?? ""
            self = .image(name)
        default:
            let colors = (try? container.decode([String].self, forKey: .colors)) ?? ["#FFFFFF"]
            self = .solid(colors.first ?? "#FFFFFF")
        }
    }

    // MARK: - Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .solid(let hex):
            try container.encode("solid", forKey: .type)
            try container.encode([hex], forKey: .colors)
        case .linear(let colors):
            try container.encode("linear", forKey: .type)
            try container.encode(colors, forKey: .colors)
        case .radial(let colors):
            try container.encode("radial", forKey: .type)
            try container.encode(colors, forKey: .colors)
        case .image(let name):
            try container.encode("image", forKey: .type)
            try container.encode(name, forKey: .image)
        }
    }

    // MARK: - Hintergrund View
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .solid(let hex):
            Color(hex: hex)
                .ignoresSafeArea()

        case .linear(let list):
            LinearGradient(
                gradient: Gradient(colors: list.map(Color.init(hex:))),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

        case .radial(let list):
            RadialGradient(
                gradient: Gradient(colors: list.map(Color.init(hex:))),
                center: .center,
                startRadius: 50,
                endRadius: 600
            )
            .ignoresSafeArea()

        case .image(let name):
            if let uiImage = UIImage(named: name) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                ZStack {
                    Color.gray.opacity(0.25)
                    VStack(spacing: 6) {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                        Text("⚠️ \(name) not found")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Theme-Modell
struct SlaykenTheme: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var background: ThemeBackground
    var textHex: String
    var buttonBackgroundHex: String
    var buttonTextHex: String
    var accentHex: String
    var category: String?
    var categoryIcon: String?
    var image: String? // optionales Overlay-Image (z. B. Charakter)

    // MARK: - Farben
    var text: Color { Color(hex: textHex) }
    var buttonBackground: Color { Color(hex: buttonBackgroundHex) }
    var buttonText: Color { Color(hex: buttonTextHex) }
    var accent: Color { Color(hex: accentHex) }
    var resolvedCategory: String { category ?? "Uncategorized" }

    // MARK: - Kombinierter Hintergrund (Farbe + optionales PNG)
    @ViewBuilder
    func fullBackgroundView(blur: CGFloat = 4, opacity: Double = 0.8) -> some View {
        ZStack {
            background.view()

            if let imageName = image, !imageName.isEmpty,
               let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(opacity)
                    .blendMode(.screen)
                    .shadow(color: .black.opacity(0.25), radius: 10)
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - Vorschau für Theme Picker
    @ViewBuilder
    var preview: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(.ultraThinMaterial)
            .background(background.view().clipShape(RoundedRectangle(cornerRadius: 14)))
            .overlay(
                VStack(spacing: 4) {
                    if let icon = categoryIcon {
                        Image(systemName: icon)
                            .font(.caption)
                            .foregroundColor(accent)
                    }
                    Text(name)
                        .font(.caption2)
                        .foregroundColor(text)
                        .lineLimit(1)
                }
                .padding(6)
            )
            .frame(width: 100, height: 60)
            .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
    }
}

// MARK: - Farb-Helper
extension Color {
    nonisolated init(hex: String) {
        var clean = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .uppercased()

        if clean.count == 3 { clean = clean.map { "\($0)\($0)" }.joined() }

        var rgb: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&rgb)

        let r, g, b, a: Double
        switch clean.count {
        case 8:
            r = Double((rgb >> 24) & 0xFF) / 255
            g = Double((rgb >> 16) & 0xFF) / 255
            b = Double((rgb >> 8) & 0xFF) / 255
            a = Double(rgb & 0xFF) / 255
        default:
            r = Double((rgb >> 16) & 0xFF) / 255
            g = Double((rgb >> 8) & 0xFF) / 255
            b = Double(rgb & 0xFF) / 255
            a = 1.0
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - Theme Loading System
func loadThemes(from fileName: String) -> [SlaykenTheme] {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        print("⚠️ \(fileName).json nicht gefunden.")
        return []
    }

    do {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([SlaykenTheme].self, from: data)
        print("✅ \(decoded.count) Themes aus \(fileName).json geladen.")
        return decoded
    } catch {
        print("❌ Fehler beim Dekodieren von \(fileName).json:", error.localizedDescription)
        return []
    }
}

// MARK: - Lade alle Themes (Slayken, Character, Seasonal, etc.)
func loadAllThemes() -> [SlaykenTheme] {
    var allThemes: [SlaykenTheme] = []
    let files = ["slaykenThemes", "characterThemes", "seasonalThemes"]

    for file in files {
        allThemes.append(contentsOf: loadThemes(from: file))
    }

    print("🎨 Insgesamt \(allThemes.count) Themes geladen (\(files.count) Dateien).")
    return allThemes
}

