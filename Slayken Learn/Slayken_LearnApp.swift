//
//  Slayken_LearnApp.swift
//  Slayken Learn
//
//  Created by Tufan Cakir on 31.10.25.
//

import SwiftUI

@main
struct Slayken_LearnApp: App {

    // MARK: - Global Managers
    @StateObject private var purchaseManager = PurchaseManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var profileManager = ProfileManager()
    @StateObject private var accountManager = AccountLevelManager()
    @StateObject private var missionManager = MissionManager()
    @StateObject private var learningEventManager = LearningEventManager()

    // MARK: - Onboarding State (persistiert)
    @AppStorage("didShowOnboarding") private var didShowOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if !didShowOnboarding {
                    OnboardingView(showOnboarding: $didShowOnboarding)
                } else {
                    RootTabView()
                        .onAppear {
                            // ✅ Daily Mission: App geöffnet
                            missionManager.trigger(.appOpened, account: accountManager)
                        }
                }
            }
            // MARK: - Environment
            .environmentObject(purchaseManager)
            .environmentObject(themeManager)
            .environmentObject(profileManager)
            .environmentObject(accountManager)
            .environmentObject(missionManager)
            .environmentObject(learningEventManager)
        }
    }
}
