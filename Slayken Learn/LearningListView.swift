import SwiftUI
import StoreKit

struct LearningListView: View {
    // MARK: - Environment
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - States
    @State private var topics: [LearningTopic] = []
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @State private var categories: [String] = []
    @State private var selectedCategory = "Alle"
    @State private var hasAskedForReviewThisSession = false

    // MARK: - Persistent Data
    @AppStorage("favoriteIDs") private var favoriteIDs = ""
    @AppStorage("appLaunchCount") private var launchCount = 0
    @AppStorage("openPurchasedTab") private var openPurchasedTab = false

    // MARK: - Computed
    private var favorites: Set<String> {
        Set(favoriteIDs.split(separator: ",").map(String.init))
    }

    private var currentTheme: SlaykenTheme? { themeManager.currentTheme }

    private var filteredTopics: [LearningTopic] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return topics.filter { topic in
            let matchCategory = selectedCategory == "Alle" || topic.category == selectedCategory
            let matchSearch =
                trimmed.isEmpty ||
                topic.title.localizedCaseInsensitiveContains(trimmed) ||
                topic.description.localizedCaseInsensitiveContains(trimmed)
            let matchFav = !showFavoritesOnly || favorites.contains(topic.id)
            return matchCategory && matchSearch && matchFav
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer

                VStack(spacing: 12) {
                    searchBar
                    favoritesToggle
                    categoryTabs
                    contentList
                }
                .padding(.vertical, 8)
                .onAppear(perform: onAppear)
            }
            .navigationTitle("Lernen")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension LearningListView {
    // MARK: - Hintergrund
    var backgroundLayer: some View {
        Group {
            if let theme = currentTheme {
                theme.fullBackgroundView()
            } else {
                LinearGradient(colors: [.black, .blue.opacity(0.8)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.35), value: currentTheme?.id)
    }

    // MARK: - Suchfeld
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Suche…", text: $searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .font(.system(size: fontSizeBase))
            if !searchText.isEmpty {
                Button {
                    withAnimation { searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.25), radius: 4, y: 1)
        .padding(.horizontal, horizontalPadding)
    }

    // MARK: - Favoriten-Toggle
    var favoritesToggle: some View {
        Toggle(isOn: $showFavoritesOnly) {
            Label("Nur Favoriten", systemImage: "heart.fill")
                .foregroundColor(currentTheme?.accent ?? .blue)
                .font(.system(size: fontSizeSmall, weight: .semibold))
        }
        .toggleStyle(SwitchToggleStyle(tint: currentTheme?.accent ?? .blue))
        .padding(.horizontal, horizontalPadding)
    }

    // MARK: - Kategorien
    var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self, content: categoryButton)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 2)
        }
        .opacity(categories.count > 1 ? 1 : 0)
        .animation(.spring(), value: categories)
    }

    func categoryButton(for category: String) -> some View {
        let selected = selectedCategory == category
        let accent = currentTheme?.buttonText ?? .blue
        return Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 6) {
                if let icon = topics.first(where: { $0.category == category })?.categoryIcon {
                    if icon.count == 1 { Text(icon) } else { Image(systemName: icon) }
                }
                Text(category)
            }
            .font(.system(size: fontSizeSmall, weight: .bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selected ? accent.opacity(0.9) : Color.white.opacity(0.08))
            .foregroundColor(selected ? .black : currentTheme?.accent ?? .white)
            .cornerRadius(8)
            .shadow(color: selected ? accent.opacity(0.3) : .clear, radius: 5)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Inhalte
    var contentList: some View {
        ScrollView {
            LazyVGrid(columns: gridLayout, spacing: 16) {
                if filteredTopics.isEmpty {
                    emptyPlaceholder
                } else {
                    ForEach(filteredTopics) { topic in
                        // 🔒 Wenn Produkt vorhanden & nicht gekauft → Lock-View
                        if let productID = topic.productID,
                           topic.category == "Gekauft",
                           !purchaseManager.isPurchased(productID) {
                            LockedContentView(topic: topic)
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
                        } else {
                            // ✅ Freigeschaltete Inhalte
                            NavigationLink(destination: LearningDetailView(topic: topic)) {
                                LearningCard(topic: topic)
                                    .scaleEffect(hoverEffect(for: topic))
                                    .animation(.easeInOut(duration: 0.2), value: topic.id)
                                    .cornerRadius(14)
                                    .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
        }
    }

    func hoverEffect(for topic: LearningTopic) -> CGFloat {
        showFavoritesOnly && favorites.contains(topic.id) ? 1.02 : 1.0
    }

    // MARK: - Leerer Zustand
    var emptyPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 42))
                .foregroundColor(.secondary)
            Text(showFavoritesOnly ? "Keine Favoriten gefunden" : "Keine Inhalte gefunden")
                .foregroundColor(.secondary)
                .font(.system(size: fontSizeBase))
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal, horizontalPadding)
    }
}

// MARK: - Layout & Dynamik
private extension LearningListView {
    var horizontalPadding: CGFloat { sizeClass == .regular ? 30 : 16 }
    var fontSizeBase: CGFloat { sizeClass == .regular ? 18 : 16 }
    var fontSizeSmall: CGFloat { sizeClass == .regular ? 16 : 14 }

    var gridLayout: [GridItem] {
        sizeClass == .regular
            ? [GridItem(.adaptive(minimum: 300), spacing: 16)]
            : [GridItem(.flexible())]
    }
}

// MARK: - Logik
private extension LearningListView {
    func onAppear() {
        loadAllTopics()
        setupCategories()
        askForReviewIfNeeded()

        if openPurchasedTab {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    selectedCategory = "Gekauft"
                }
                openPurchasedTab = false
            }
        }
    }

    func loadAllTopics() {
        let files = ["learningTopics", "metalData", "metalShaderData", "metalAppData", "reactNativeData", "purchasedContent"]
        topics = files.flatMap { loadLearningTopics(from: $0) }
    }

    func setupCategories() {
        let unique = Set(topics.map { $0.category })
        categories = ["Alle"] + unique.sorted()
        if !categories.contains(selectedCategory) {
            selectedCategory = "Alle"
        }
    }

    func askForReviewIfNeeded() {
        launchCount += 1
        guard topics.count > 3 else { return }

        if (launchCount == 5 || launchCount % 10 == 0), !hasAskedForReviewThisSession {
            hasAskedForReviewThisSession = true
            requestAppStoreReview()
        }
    }

    func requestAppStoreReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else { return }

        if #available(iOS 18.0, *) {
            AppStore.requestReview(in: scene)
        } else {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

// MARK: - Code Loader
func loadCode(from fileName: String) -> String {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: nil),
          let code = try? String(contentsOf: url, encoding: .utf8) else {
        return "// Datei nicht gefunden: \(fileName)"
    }
    return code
}

// MARK: - Preview
#Preview {
    LearningListView()
        .environmentObject(ThemeManager())
        .environmentObject(PurchaseManager())
        .preferredColorScheme(.dark)
}
