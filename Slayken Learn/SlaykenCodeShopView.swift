//
//  SlaykenCodeShopView.swift
//  Slayken Learn
//
//  Created by Tufan Cakir on 2025-11-04.
//

import SwiftUI
import StoreKit

// MARK: - Shop Model
struct ShopItem: Identifiable, Codable {
    let id: String
    let productID: String
    let title: String
    let description: String
    let colors: ShopColors
    let priceTier: String?
    let previewImage: String?
    let shopCode: String?
    let category: String
    let categoryIcon: String
    let categoryIconColor: String

    enum CodingKeys: String, CodingKey {
        case id, productID, title, description, colors, priceTier, previewImage, shopCode, category, categoryIcon, categoryIconColor, code
    }

    // MARK: - Decoding (liest sowohl "shopCode" als auch "code")
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        productID = try container.decode(String.self, forKey: .productID)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        colors = try container.decode(ShopColors.self, forKey: .colors)
        priceTier = try? container.decode(String.self, forKey: .priceTier)
        previewImage = try? container.decode(String.self, forKey: .previewImage)
        // Fallback: shopCode oder code
        shopCode = try? container.decode(String.self, forKey: .shopCode)
        category = try container.decode(String.self, forKey: .category)
        categoryIcon = try container.decode(String.self, forKey: .categoryIcon)
        categoryIconColor = try container.decode(String.self, forKey: .categoryIconColor)
    }

    // MARK: - Encoding (schreibt immer "shopCode")
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(productID, forKey: .productID)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(colors, forKey: .colors)
        try container.encodeIfPresent(priceTier, forKey: .priceTier)
        try container.encodeIfPresent(previewImage, forKey: .previewImage)
        try container.encodeIfPresent(shopCode, forKey: .shopCode)
        try container.encode(category, forKey: .category)
        try container.encode(categoryIcon, forKey: .categoryIcon)
        try container.encode(categoryIconColor, forKey: .categoryIconColor)
    }
}

// MARK: - Farbstruktur
struct ShopColors: Codable {
    let backgroundColors: [String]
    let textColors: [String]
}


// MARK: - Hauptansicht
@MainActor
struct SlaykenCodeShopView: View {
    let preselectedProductID: String? // optional für „gesperrten Code anzeigen“

    // MARK: - Environment
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var purchaseManager: PurchaseManager

    // MARK: - States
    @State private var shopItems: [ShopItem] = []
    @State private var products: [Product] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showRestoreToast = false
    @State private var navigateToLearning = false
    @State private var selectedCategory = "Alle"

    // MARK: - Storage
    @AppStorage("openPurchasedTab") private var openPurchasedTab = false

    private var currentTheme: SlaykenTheme? { themeManager.currentTheme }

    // MARK: - Gefilterte Items
    private var filteredItems: [ShopItem] {
        selectedCategory == "Alle"
            ? shopItems
            : shopItems.filter { $0.category == selectedCategory }
    }

    // MARK: - Sortierte Kategorien
    private var sortedCategories: [String] {
        let unique = Array(Set(shopItems.map(\.category))).sorted()
        return ["Alle"] + unique
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                contentView
            }
            .navigationTitle("Code-Shop")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: purchaseManager.purchaseStateDidChange) { await setupShop() }
            .task { await setupShop() }
            .navigationDestination(isPresented: $navigateToLearning) {
                LearningListView()
                    .environmentObject(themeManager)
                    .environmentObject(purchaseManager)
            }
            .overlay(restoreToastView, alignment: .bottom)
        }
    }
}

// MARK: - Setup & Logik
private extension SlaykenCodeShopView {
    func setupShop() async {
        do {
            isLoading = true
            try await loadShopData()
            try await loadProducts()
            withAnimation(.easeInOut(duration: 0.3)) { isLoading = false }
        } catch {
            showError(error.localizedDescription)
        }
    }

    func loadShopData() async throws {
        guard let url = Bundle.main.url(forResource: "shopData", withExtension: "json") else {
            throw URLError(.fileDoesNotExist,
                           userInfo: [NSLocalizedDescriptionKey: "shopData.json nicht gefunden"])
        }
        let data = try Data(contentsOf: url)
        shopItems = try JSONDecoder().decode([ShopItem].self, from: data)
    }

    func loadProducts() async throws {
        let ids = shopItems.map(\.productID)
        products = try await Product.products(for: ids)
    }

    func handlePurchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result,
               case .verified(let transaction) = verification {
                purchaseManager.markPurchased(transaction.productID)
                await transaction.finish()
                openPurchasedTab = true
                navigateToLearning = true
            }
        } catch {
            showError("Fehler beim Kauf: \(error.localizedDescription)")
        }
    }

    func showError(_ message: String) {
        withAnimation { isLoading = false }
        errorMessage = message
    }
}

// MARK: - View Components
private extension SlaykenCodeShopView {
    @ViewBuilder
    var contentView: some View {
        if isLoading {
            VStack(spacing: 12) {
                ProgressView("Lade Code-Shop …")
                    .progressViewStyle(.circular)
                    .tint(currentTheme?.accent ?? .blue)
                Text("Bitte warten …")
                    .foregroundColor(.white.opacity(0.7))
            }
            .transition(.opacity)

        } else if let errorMessage {
            errorView(message: errorMessage)

        } else {
            ScrollView {
                VStack(spacing: 24) {
                    restoreButton

                    // Kategorien-Leiste
                    if sortedCategories.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(sortedCategories, id: \.self) { category in
                                    let colorHex = shopItems.first(where: { $0.category == category })?.categoryIconColor ?? "#0A84FF"
                                    categoryButton(title: category, color: Color(hex: colorHex))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }

                    // Produktkarten
                    LazyVStack(spacing: 22) {
                        ForEach(filteredItems) { item in
                            if let product = products.first(where: { $0.id == item.productID }) {
                                SlaykenShopCard(
                                    item: item,
                                    product: product,
                                    purchased: purchaseManager.isPurchased(product.id),
                                    accentColor: currentTheme?.accent ?? .blue
                                ) {
                                    Task {
                                        if purchaseManager.isPurchased(product.id) {
                                            navigateToLearning = true
                                        } else {
                                            await handlePurchase(product)
                                        }
                                    }
                                }
                                .transition(.opacity.combined(with: .scale))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 20)
            }
        }
    }

    // MARK: Kategorie-Button
    func categoryButton(title: String, color: Color) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedCategory = title
            }
        } label: {
            HStack(spacing: 6) {
                if let icon = shopItems.first(where: { $0.category == title })?.categoryIcon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.subheadline.bold())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(selectedCategory == title ? color.opacity(0.9) : Color.white.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(selectedCategory == title ? 1 : 0.3), lineWidth: 1.2)
            )
            .foregroundColor(.white)
            .shadow(color: color.opacity(selectedCategory == title ? 0.5 : 0), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: Hintergrund
    var backgroundView: some View {
        Group {
            if let theme = currentTheme {
                theme.fullBackgroundView()
            } else {
                LinearGradient(colors: [.black, .blue.opacity(0.9)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            }
        }
        .ignoresSafeArea()
        .overlay(Color.black.opacity(0.25))
    }

    // MARK: Fehleranzeige
    func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 42))
                .foregroundColor(.yellow)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.subheadline)
            Button("Erneut versuchen") {
                Task { await setupShop() }
            }
            .padding(.top, 4)
        }
        .padding()
    }

    // MARK: Restore-Button
    var restoreButton: some View {
        Button {
            Task {
                await purchaseManager.restorePurchases()
                haptic(.medium)
                withAnimation(.spring()) { showRestoreToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut) { showRestoreToast = false }
                }
            }
        } label: {
            Label("Käufe wiederherstellen", systemImage: "arrow.clockwise.circle.fill")
                .font(.subheadline.bold())
                .foregroundColor(currentTheme?.accent ?? .blue)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.25), radius: 5, y: 2)
        }
    }

    // MARK: Restore-Toast
    @ViewBuilder
    var restoreToastView: some View {
        if showRestoreToast {
            Text("✅ Käufe erfolgreich wiederhergestellt")
                .font(.caption.bold())
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.9))
                .cornerRadius(12)
                .foregroundColor(.white)
                .padding(.bottom, 22)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: Haptik
    func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

// MARK: - Shop Card
struct SlaykenShopCard: View {
    let item: ShopItem
    let product: ProductProtocol
    let purchased: Bool
    let accentColor: Color
    let onBuy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 🔹 Preview Image
            if let imageName = item.previewImage,
               let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(height: 230)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.6))
                    )
            }

            // 🔹 Informationen
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: item.categoryIcon)
                        .foregroundColor(Color(hex: item.categoryIconColor))
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)

                HStack {
                    Text(product.displayPrice)
                        .fontWeight(.semibold)
                        .foregroundColor(accentColor)
                    Spacer()
                    Button(purchased ? "Anzeigen 👀" : "Kaufen", action: onBuy)
                        .buttonStyle(.borderedProminent)
                        .tint(purchased ? .green : accentColor)
                        .animation(.easeInOut, value: purchased)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.35), radius: 10, y: 5)
        .padding(.horizontal)
        .transition(.opacity)
    }
}

// MARK: - Product Protocol
protocol ProductProtocol {
    var id: String { get }
    var displayPrice: String { get }
}

extension Product: ProductProtocol {}
struct MockProduct: ProductProtocol { var id: String; var displayPrice: String }

// MARK: - Preview
#Preview {
    SlaykenCodeShopView(preselectedProductID: nil)
        .environmentObject(ThemeManager())
        .environmentObject(PurchaseManager())
        .preferredColorScheme(.dark)
}
