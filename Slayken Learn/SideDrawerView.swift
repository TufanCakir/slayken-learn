import SwiftUI

struct SideDrawerView: View {
    @Binding var showDrawer: Bool
    @State private var sections: [DrawerSection] = []
    @State private var groupedSections: [String: [DrawerSection]] = [:]
    @State private var selectedCategory: String = "Alle"

    // 🟢 Zugriff auf ThemeManager
    @EnvironmentObject private var themeManager: ThemeManager
    private var currentTheme: SlaykenTheme? { themeManager.currentTheme }

    // 🔹 Computed
    private var categories: [String] {
        let all = groupedSections.keys.sorted()
        return ["Alle"] + all
    }

    private var filteredSections: [DrawerSection] {
        if selectedCategory == "Alle" {
            return sections
        } else {
            return groupedSections[selectedCategory] ?? []
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // MARK: - Header
            headerView

            // MARK: - Kategorie-Tabs
            categoryTabs

            // MARK: - Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(filteredSections) { section in
                        NavigationLink(destination: DrawerDetailView(section: section)) {
                            sectionCard(for: section)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded {
                            withAnimation(.spring()) { showDrawer = false }
                        })
                    }

                    if filteredSections.isEmpty {
                        emptyPlaceholder
                    }
                }
                .padding(.vertical, 10)
            }

            Spacer(minLength: 8)

            Divider().background((currentTheme?.text ?? .white).opacity(0.15))

            // MARK: - Footer
            closeButton
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundView)
        .onAppear(perform: loadAndGroupSections)
    }
}

private extension SideDrawerView {
    // MARK: - Header
    var headerView: some View {
        HStack(spacing: 10) {
            Image(systemName: "book.fill")
                .font(.system(size: 26))
                .foregroundColor(currentTheme?.accent ?? .blue)
            Text("Dokumentation")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(currentTheme?.accent ?? .white)
        }
        .padding(.bottom, 10)
        .transition(.opacity.combined(with: .scale))
    }
    
    // MARK: - Kategorie Tabs
    var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            selectedCategory = category
                        }
                    } label: {
                        HStack(spacing: 6) {
                            if let icon = groupedSections[category]?.first?.categoryIcon {
                                if icon.count == 1 {
                                    Text(icon)
                                        .font(.system(size: 16))
                                } else if UIImage(systemName: icon) != nil {
                                    Image(systemName: icon)
                                        .font(.system(size: 15))
                                }
                            }
                            Text(category)
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    selectedCategory == category
                                    ? (currentTheme?.accent ?? .blue).opacity(0.9)
                                    : Color.white.opacity(0.1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(currentTheme?.accent ?? .blue, lineWidth: selectedCategory == category ? 1.5 : 0.5)
                                )
                        )
                        .foregroundColor(
                            selectedCategory == category
                            ? (currentTheme?.buttonText ?? .black)
                            : (currentTheme?.text ?? .white).opacity(0.8)
                        )
                        .shadow(color: (currentTheme?.accent ?? .blue).opacity(selectedCategory == category ? 0.6 : 0),
                                radius: selectedCategory == category ? 6 : 0)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 8)
        }
    }
    
    // MARK: - Section Cards
    func sectionCard(for section: DrawerSection) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(section.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(currentTheme?.text ?? .white)
            
            Text(section.description)
                .font(.system(size: 13))
                .foregroundColor((currentTheme?.text ?? .white).opacity(0.7))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(currentTheme?.accent ?? .blue, lineWidth: 0.5)
                )
        )
    }
    
    
    
    // MARK: - Empty State
    var emptyPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 30))
                .foregroundColor(.secondary)
            Text("Keine Inhalte gefunden")
                .foregroundColor(.secondary)
                .font(.system(size: 15))
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding(.top, 40)
    }
    
    // MARK: - Footer
    var closeButton: some View {
        Button {
            withAnimation(.spring()) { showDrawer = false }
        } label: {
            Label("Schließen", systemImage: "xmark")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(currentTheme?.buttonText ?? .white)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(currentTheme?.accent ?? .gray)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(currentTheme?.accent ?? .blue, lineWidth: 1)
                )
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Hintergrund
    var backgroundView: some View {
        Group {
            if let theme = currentTheme {
                theme.background.view()
            } else {
                LinearGradient(colors: [.black, .blue.opacity(0.85)],
                               startPoint: .top, endPoint: .bottom)
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Daten laden
    private func loadAndGroupSections() {
        let jsonFiles = [
            "drawerSections",
            "drawerMetalData",
            "drawerRealityKitData",
            "drawerSpriteKitData",
            "drawerSwiftUIData",
            "drawerSwiftData",
            "drawerARKitData",
            "drawerHealthKitData",
            "drawerVisionData",
            "drawerwidgeKitData",
            "drawerSpeechData",
            "drawerSwiftDataModel"
        ]
        
        var combinedSections: [DrawerSection] = []
        
        for file in jsonFiles {
            if let url = Bundle.main.url(forResource: file, withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([DrawerSection].self, from: data) {
                combinedSections.append(contentsOf: decoded)
            }
        }
        
        sections = combinedSections.sorted { $0.title < $1.title }
        groupedSections = Dictionary(grouping: sections, by: { $0.category })
        
        if !groupedSections.keys.contains(selectedCategory) {
            selectedCategory = "Alle"
        }
    }
}

#Preview {
    SideDrawerView(showDrawer: .constant(true))
        .environmentObject(ThemeManager())
        .preferredColorScheme(.dark)
}
