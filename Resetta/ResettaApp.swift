//
//  ResettaApp.swift
//  Resetta
//
//  Created by Wiktor on 15/05/2026.
//

import SwiftUI
import SwiftData

@main
struct ResettaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var sessionTimer = SessionTimerService()
    @State private var sessionStorage = SessionStorageService()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(sessionTimer)
                .environment(sessionStorage)
        }
        .modelContainer(for: DetoxSession.self)
    }
}
