import SwiftUI

struct DrawerListView: View {
    @State private var sections: [DrawerSection] = []
    
    var body: some View {
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
        }
        .onAppear(perform: loadJSON)
    }
    
    func loadJSON() {
        guard let url = Bundle.main.url(forResource: "drawerSections", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }
        sections = (try? JSONDecoder().decode([DrawerSection].self, from: data)) ?? []
    }
}

#Preview {
    DrawerListView()
}
