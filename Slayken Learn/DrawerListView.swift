import SwiftUI

struct DrawerListView: View {
    @State private var sections: [DrawerSection] = []
    
    var body: some View {
        NavigationStack {
            List(sections) { section in
                VStack(alignment: .leading, spacing: 6) {
                    Text(section.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(section.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: section.colors.backgroundColors.compactMap { Color(hex: $0) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Dokumentation")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadAllDrawers)
        }
    }
}

private extension DrawerListView {
    /// 🔹 Lädt alle Drawer-JSON-Dateien automatisch
    func loadAllDrawers() {
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
            "drawerSwiftDataModel",
            "drawerHtmlData"
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
    }
}

#Preview {
    DrawerListView()
        .preferredColorScheme(.dark)
}
