//
//  ValeApp.swift
//  Vale
//
//  Created by Wiktor on 15/05/2026.
//

import SwiftUI
import SwiftData

@main
struct ValeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var sessionTimer = SessionTimerService()
    @State private var sessionStorage = SessionStorageService()
    private let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([DetoxSession.self])
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create local session store: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(sessionTimer)
                .environment(sessionStorage)
        }
        .modelContainer(modelContainer)
    }
}
