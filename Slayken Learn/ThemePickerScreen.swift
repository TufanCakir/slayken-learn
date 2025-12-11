import SwiftUI

struct ThemePickerScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("selectedThemeIndex") private var selectedThemeIndex = 0
    @State private var selectedCategory: String = "All"

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // MARK: - Berechnete Themes nach Filter
    private var filteredThemes: [SlaykenTheme] {
        selectedCategory == "All"
            ? themeManager.themes
            : themeManager.themes.filter { $0.category == selectedCategory }
    }

    // MARK: - Alle Kategorien
    private var categories: [String] {
        let base = ["All"]
        let jsonCats = themeManager.themes.compactMap { $0.category }
            .removingDuplicates()
            .sorted()
        return base + jsonCats
    }

    var body: some View {
        ZStack {
            // MARK: - Dynamischer Hintergrund
            if let currentTheme = themeManager.currentTheme {
                currentTheme.fullBackgroundView(blur: 6, opacity: 0.7)
                    .overlay(Color.black.opacity(0.1))
                    .animation(.easeInOut(duration: 0.35), value: selectedThemeIndex)
            } else {
                Color(.systemBackground).ignoresSafeArea()
            }

            VStack(spacing: 0) {
                // MARK: - Kategorieauswahl
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            categoryButton(for: category)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .background(.white)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 4)

                // MARK: - Theme Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredThemes.indices, id: \.self) { index in
                            let theme = filteredThemes[index]
                            themeCard(theme: theme,
                                      isSelected: theme.id == themeManager.currentTheme?.id)
                                .onTapGesture {
                                    if let indexInFullList = themeManager.themes.firstIndex(where: { $0.id == theme.id }) {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                            selectedThemeIndex = indexInFullList
                                            themeManager.selectTheme(at: indexInFullList)
                                            Haptic.selection()
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 60)
                }
            }
            .navigationTitle("Themes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Kategorie Button
    private func categoryButton(for category: String) -> some View {
        let isSelected = category == selectedCategory

        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                selectedCategory = category
                Haptic.selection()
            }
        }) {
            HStack(spacing: 6) {
                if category != "All" {
                    if let icon = themeManager.themes
                        .first(where: { $0.category == category })?
                        .categoryIcon {
                        Image(systemName: icon)
                            .font(.caption)
                    }
                }
                Text(category)
                    .font(.footnote.weight(.semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.25)
                                     : Color.secondary.opacity(0.1))
            )
            .foregroundColor(isSelected ? .primary : .secondary)
        }
    }

    // MARK: - Theme Card
    private func themeCard(theme: SlaykenTheme, isSelected: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                // 🔹 Dynamische Kombination: Farbe + optionales Bild
                theme.fullBackgroundView(blur: 3, opacity: 0.9)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.15))
                    )

                // 🔹 Text & Info
                VStack(spacing: 6) {
                    if let category = theme.category {
                        HStack(spacing: 4) {
                            if let icon = theme.categoryIcon {
                                Image(systemName: icon)
                                    .font(.caption)
                                    .foregroundColor(theme.accent)
                            }
                            Text(category.uppercased())
                                .font(.caption2.bold())
                                .foregroundColor(theme.accent)
                        }
                    }

                    Text(theme.name)
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(theme.text)
                        .shadow(color: .black.opacity(0.25), radius: 1, y: 1)

                    HStack(spacing: 6) {
                        Circle().fill(theme.buttonBackground).frame(width: 12, height: 12)
                        Circle().fill(theme.accent).frame(width: 12, height: 12)
                    }
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 1)
            }
            .frame(height: 130)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? theme.accent : .clear, lineWidth: 3)
                    .shadow(color: theme.accent.opacity(isSelected ? 0.5 : 0), radius: 6)
            )
            .scaleEffect(isSelected ? 1.04 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.85), value: isSelected)

            Text(theme.name)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? theme.accent : .secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Array Extension
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

// MARK: - Haptic Feedback
enum Haptic {
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ThemePickerScreen()
            .environmentObject(ThemeManager())
    }
}
