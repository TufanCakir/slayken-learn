import SwiftUI
import StoreKit

struct LearningListView: View {

    // MARK: - Environment
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.horizontalSizeClass) private var sizeClass

    // MARK: - Storage
    @AppStorage("favoriteIDs") private var favoriteIDs = ""

    // MARK: - ViewModel
    @StateObject private var vm: LearningListViewModel

    init() {
        let favs = Set(
            UserDefaults.standard
                .string(forKey: "favoriteIDs")?
                .split(separator: ",")
                .map(String.init) ?? []
        )
        _vm = StateObject(wrappedValue: LearningListViewModel(favorites: favs))
    }

    private var theme: SlaykenTheme? { themeManager.currentTheme }

    var body: some View {
        VStack(spacing: 12) {
            searchBar
            favoritesToggle
            categoryTabs

            LearningGrid(
                topics: vm.filteredTopics,
                purchaseManager: purchaseManager,
                gridLayout: gridLayout
            )
        }
        .padding(.vertical, 8)
        .background(background)
        .navigationTitle("Lernen")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LearningGrid: View {

    let topics: [LearningTopic]
    let purchaseManager: PurchaseManager
    let gridLayout: [GridItem]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridLayout, spacing: 16) {

                if topics.isEmpty {
                    EmptyStateView()
                }

                ForEach(topics) { topic in
                    if let productID = topic.productID,
                       !purchaseManager.isPurchased(productID) {

                        LockedContentView(topic: topic)

                    } else {
                        NavigationLink {
                            LearningDetailView(topic: topic)
                        } label: {
                            LearningCard(topic: topic)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
    }
}

private extension LearningListView {

    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Suche…", text: $vm.searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)

            if !vm.searchText.isEmpty {
                Button {
                    withAnimation { vm.searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding(.horizontal, horizontalPadding)
    }

    var favoritesToggle: some View {
        Toggle(isOn: $vm.showFavoritesOnly) {
            Label("Nur Favoriten", systemImage: "heart.fill")
        }
        .toggleStyle(.switch)
        .tint(theme?.accent ?? .black)
        .padding(.horizontal, horizontalPadding)
        .background(.ultraThinMaterial)
    }

    var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(vm.categories, id: \.self) { category in
                    categoryButton(category)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .background(.ultraThinMaterial)
        }
    }

    func categoryButton(_ category: String) -> some View {
        let selected = vm.selectedCategory == category

        return Button {
            withAnimation(.spring()) {
                vm.selectedCategory = category
            }
        } label: {
            Text(category)
                .font(.system(size: fontSizeSmall, weight: .bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selected ? (theme?.accent ?? .blue) : Color.white.opacity(0.08))
                .foregroundColor(selected ? .black : .white)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

private extension LearningListView {

    var background: some View {
        Group {
            if let theme {
                theme.fullBackgroundView()
            } else {
                LinearGradient(
                    colors: [.black, .blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .ignoresSafeArea()
    }

    var horizontalPadding: CGFloat { sizeClass == .regular ? 30 : 16 }
    var fontSizeSmall: CGFloat { sizeClass == .regular ? 16 : 14 }

    var gridLayout: [GridItem] {
        sizeClass == .regular
            ? [GridItem(.adaptive(minimum: 300), spacing: 16)]
            : [GridItem(.flexible())]
    }
}


// MARK: - Preview
#Preview {
    LearningListView()
        .environmentObject(ThemeManager())
        .environmentObject(PurchaseManager())
        .preferredColorScheme(.dark)
}
