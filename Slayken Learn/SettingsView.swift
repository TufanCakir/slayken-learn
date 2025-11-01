import SwiftUI
import StoreKit

enum AppAppearance: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Hell"
    case dark = "Dunkel"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.fill"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
}

struct SettingsView: View {
    @Environment(\.requestReview) private var requestReview
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.system.rawValue

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dynamicTypeSize) private var dynamicType

    private var appearance: AppAppearance {
        get { AppAppearance(rawValue: appearanceRaw) ?? .system }
        set { appearanceRaw = newValue.rawValue }
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Darstellung
                Section {
                    Picker("App-Darstellung", selection: $appearanceRaw) {
                        ForEach(AppAppearance.allCases) { mode in
                            Label(mode.rawValue, systemImage: mode.icon)
                                .font(.system(size: fontSizeBase))
                                .tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
                } header: {
                    Text("Darstellung")
                        .font(.system(size: fontSizeHeadline, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                // MARK: - Feedback
                Section {
                    Button {
                        requestReview()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: iconSize))
                            Text("App bewerten (In-App)")
                                .foregroundColor(.primary)
                                .font(.system(size: fontSizeBase))
                        }
                        .padding(.vertical, buttonPadding)
                    }

                    Button {
                        openAppStoreReviewPage()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "link")
                                .foregroundColor(.blue)
                                .font(.system(size: iconSize))
                            Text("Im App Store bewerten")
                                .foregroundColor(.primary)
                                .font(.system(size: fontSizeBase))
                        }
                        .padding(.vertical, buttonPadding)
                    }
                } header: {
                    Text("Feedback")
                        .font(.system(size: fontSizeHeadline, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.1), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(AppAppearance(rawValue: appearanceRaw)?.colorScheme)
    }

    // MARK: - App Store Review Page öffnen
    private func openAppStoreReviewPage() {
        let appID = "6754783883" // Deine echte App-ID
        if let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Dynamische Größen
private extension SettingsView {
    var fontSizeHeadline: CGFloat {
        sizeClass == .regular ? 22 : 18
    }
    var fontSizeBase: CGFloat {
        sizeClass == .regular ? 18 : 16
    }
    var iconSize: CGFloat {
        sizeClass == .regular ? 20 : 16
    }
    var buttonPadding: CGFloat {
        sizeClass == .regular ? 8 : 4
    }
}

#Preview {
    SettingsView()
}
