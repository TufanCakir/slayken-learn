import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    private var currentTheme: SlaykenTheme? { themeManager.currentTheme }

    var body: some View {
        ZStack {
            // MARK: - Hintergrund
            backgroundLayer

            VStack(spacing: 30) {
                // MARK: - Titel
                Text("Profil")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(currentTheme?.text ?? .white)
                    .padding(.top, safeTopInset() + 10)

                // MARK: - Avatar
                avatarSection

                // MARK: - Eingabefeld
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dein Name")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor((currentTheme?.accent ?? .white).opacity(0.6))

                    TextField("Name eingeben …", text: $profileManager.name)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .padding()
                        .background(currentTheme?.buttonBackground.opacity(0.15) ?? Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(currentTheme?.accent ?? .black, lineWidth: 1)
                        )
                        .foregroundColor(currentTheme?.accent ?? .white)
                }
                .padding(.horizontal, 32)

                // MARK: - Speichern Button
                Button {
                    withAnimation(.spring()) {
                        profileManager.saveProfile()
                        dismiss()
                    }
                } label: {
                    Label("Speichern", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(currentTheme?.accent ?? .white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(currentTheme?.buttonBackground ?? .blue)
                        )
                        .shadow(color: (currentTheme?.accent ?? .black).opacity(0.3), radius: 8, y: 4)
                        .padding(.horizontal, 32)
                }

                // MARK: - Reset Button
                Button(role: .destructive) {
                    withAnimation(.spring()) {
                        profileManager.resetProfile()
                    }
                } label: {
                    Label("Zurücksetzen", systemImage: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                }

                Spacer()
            }
        }
        .ignoresSafeArea(edges: .top)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Unterkomponenten
private extension ProfileView {
    // MARK: - Hintergrund
    var backgroundLayer: some View {
        Group {
            if let bg = currentTheme?.background.view() {
                bg
            } else {
                LinearGradient(colors: [.black, .blue.opacity(0.9)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.35), value: currentTheme?.id)
    }

    // MARK: - Avatar
    var avatarSection: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 120, height: 120)
                .overlay(
                    Circle()
                        .stroke(currentTheme?.accent ?? .blue, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.4), radius: 6, y: 3)

            Image(systemName: "person.fill")
                .font(.system(size: 60))
                .foregroundColor(currentTheme?.accent ?? .blue)
        }
    }

    // MARK: - SafeArea Helper
    func safeTopInset() -> CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.safeAreaInsets.top }
            .first ?? 0
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environmentObject(ProfileManager())
        .environmentObject(ThemeManager())
        .preferredColorScheme(.dark)
}
