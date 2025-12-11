//
//  Slayken_LearnApp.swift
//  Slayken Learn
//
//  Created by Tufan Cakir on 31.10.25.
//

import SwiftUI

@main
struct Slayken_LearnApp: App {
    @StateObject private var purchaseManager = PurchaseManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var profileManager = ProfileManager()
    @StateObject var accountManager = AccountLevelManager()
    @StateObject var missionManager = MissionManager()

    @State private var showOnboarding = true
    
    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
                    .environmentObject(themeManager)
                    .environmentObject(profileManager)
            } else {
                RootTabView()
                    .environmentObject(purchaseManager)
                    .environmentObject(themeManager)
                    .environmentObject(profileManager)
                    .environmentObject(accountManager)
                    .environmentObject(missionManager)
            }
        }
    }
}
