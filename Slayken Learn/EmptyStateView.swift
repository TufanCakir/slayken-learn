import SwiftUI

struct EmptyStateView: View {

    var title: String = "Keine Inhalte gefunden"
    var subtitle: String = "Versuche eine andere Suche oder Kategorie."

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    EmptyStateView()
        .preferredColorScheme(.dark)
}
