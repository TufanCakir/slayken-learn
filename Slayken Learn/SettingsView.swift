import SwiftUI
import StoreKit

// MARK: - Darstellungsauswahl
enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: LocalizedStringKey {
        switch self {
        case .system: "System"
        case .light:  "Hell"
        case .dark:   "Dunkel"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light:  .light
        case .dark:   .dark
        }
    }

    var icon: String {
        switch self {
        case .system: "circle.lefthalf.fill"
        case .light:  "sun.max.fill"
        case .dark:   "moon.fill"
        }
    }
}


// MARK: - Einstellungen
struct SettingsView: View {

    // MARK: - Environment
    @Environment(\.requestReview) private var requestReview
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.horizontalSizeClass) private var sizeClass

    // MARK: - AppStorage
    @AppStorage("appAppearance") private var appearance: AppAppearance = .system

    // MARK: - UI State
    @State private var showResetConfirmation = false
    @State private var showResetSuccess = false
    @State private var isResetting = false

    var body: some View {
        NavigationStack {
            List {
                appearanceSection
                debugSection
                feedbackSection
            }
            .scrollContentBackground(.hidden)
            .background(backgroundView)
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(appearance.colorScheme)
            .alert(resetAlertTitle, isPresented: $showResetConfirmation) {
                resetAlertButtons
            } message: {
                Text("Alle bisherigen Käufe werden gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.")
            }
            .overlay(successToast, alignment: .bottom)
            .overlay(loadingOverlay)
        }
    }
}

private extension SettingsView {

    var appearanceSection: some View {
        Section(header: sectionHeader("Darstellung")) {
            Picker("App-Darstellung", selection: $appearance) {
                ForEach(AppAppearance.allCases) { mode in
                    Label(mode.displayName, systemImage: mode.icon)
                        .tag(mode)
                }
            }
            .pickerStyle(.inline)
        }
    }

    var debugSection: some View {
        Section(header: sectionHeader("Debug / Test")) {
            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                Label("Alle Käufe zurücksetzen", systemImage: "trash.fill")
            }
            .disabled(isResetting)
        }
    }

    var feedbackSection: some View {
        Section(header: sectionHeader("Feedback")) {

            Button {
                requestReview()
                haptic(.light)
            } label: {
                Label("App bewerten (In-App)", systemImage: "star.fill")
                    .foregroundColor(.yellow)
            }

            Button {
                openAppStoreReviewPage()
                haptic(.medium)
            } label: {
                Label("Im App Store bewerten", systemImage: "link")
                    .foregroundColor(.blue)
            }
        }
    }
}

private extension SettingsView {

    func resetAllPurchases() {
        isResetting = true
        haptic(.heavy)

        Task {
            await purchaseManager.resetPurchases()

            try? await Task.sleep(for: .milliseconds(300))

            withAnimation {
                showResetSuccess = true
                isResetting = false
            }

            purchaseManager.purchaseStateDidChange.toggle()

            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                showResetSuccess = false
            }
        }
    }
}
private extension SettingsView {

    var resetAlertTitle: String {
        "Käufe wirklich zurücksetzen?"
    }

    var resetAlertButtons: some View {
        Group {
            Button("Abbrechen", role: .cancel) {}
            Button("Ja, zurücksetzen", role: .destructive) {
                resetAllPurchases()
            }
        }
    }

    var backgroundView: some View {
        LinearGradient(
            colors: [.black.opacity(0.1), .clear],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    var successToast: some View {
        Group {
            if showResetSuccess {
                Text("✅ Käufe erfolgreich zurückgesetzt")
                    .font(.caption.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.green.opacity(0.9))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    var loadingOverlay: some View {
        Group {
            if isResetting {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView("Wird zurückgesetzt…")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
            }
        }
    }

    func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: fontSizeHeadline, weight: .semibold))
            .foregroundStyle(.secondary)
    }

    func openAppStoreReviewPage() {
        let appID = "6754783883"
        guard let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") else { return }
        UIApplication.shared.open(url)
    }

    func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

private extension SettingsView {
    var fontSizeHeadline: CGFloat { sizeClass == .regular ? 22 : 18 }
}


#Preview {
    SettingsView()
        .environmentObject(PurchaseManager())
}
