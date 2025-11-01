import SwiftUI

struct LearningCard: View {
    let topic: LearningTopic

    // Favoriten persistent speichern
    @AppStorage("favoriteIDs") private var favoriteIDs = ""
    @State private var showShareSheet = false

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var favorites: Set<String> {
        Set(favoriteIDs.split(separator: ",").map(String.init))
    }

    private var primaryTextColor: Color {
        Color(hex: topic.colors.textColors.first ?? "#FFFFFF")
    }

    private var secondaryTextColor: Color {
        let hex = topic.colors.textColors.dropFirst().first ?? (topic.colors.textColors.first ?? "#FFFFFF")
        return Color(hex: hex).opacity(0.9)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Hintergrund
            LinearGradient(
                colors: topic.colors.backgroundColors.map { Color(hex: $0) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)

            // Icon (optional)
            if let icon = topic.icon {
                Text(icon)
                    .font(.system(size: iconSize))
                    .padding([.top, .trailing], 12)
            }

            VStack(alignment: .leading, spacing: 8) {
                Spacer(minLength: 0)

                Text(topic.title)
                    .font(titleFont)
                    .foregroundColor(primaryTextColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(topic.description)
                    .font(descriptionFont)
                    .foregroundColor(secondaryTextColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                HStack {
                    Button {
                        toggleFavorite()
                    } label: {
                        Label("Favorit", systemImage: favorites.contains(topic.id) ? "heart.fill" : "heart")
                            .font(actionFont)
                            .foregroundColor(primaryTextColor)
                    }

                    Spacer()

                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Teilen", systemImage: "square.and.arrow.up")
                            .font(actionFont)
                            .foregroundColor(primaryTextColor)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [topic.code])
        }
    }

    // MARK: - Dynamische Layout-Berechnung

    private var cardHeight: CGFloat {
        sizeClass == .regular ? 240 : 200
    }

    private var iconSize: CGFloat {
        sizeClass == .regular ? 40 : 30
    }

    private var titleFont: Font {
        sizeClass == .regular ? .title2.bold() : .headline.bold()
    }

    private var descriptionFont: Font {
        sizeClass == .regular ? .subheadline : .caption
    }

    private var actionFont: Font {
        sizeClass == .regular ? .footnote : .caption2
    }

    // MARK: - Favoriten-Logik
    private func toggleFavorite() {
        var set = favorites
        if set.contains(topic.id) {
            set.remove(topic.id)
        } else {
            set.insert(topic.id)
        }
        favoriteIDs = set.joined(separator: ",")
    }
}

// MARK: - ShareSheet bleibt gleich
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
