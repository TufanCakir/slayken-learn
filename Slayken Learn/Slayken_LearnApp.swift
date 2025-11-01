//
//  Slayken_LearnApp.swift
//  Slayken Learn
//
//  Created by Tufan Cakir on 31.10.25.
//

import SwiftUI

@main
struct Slayken_LearnApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var profileManager = ProfileManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(themeManager)
                .environmentObject(profileManager)
        }
    }
}
