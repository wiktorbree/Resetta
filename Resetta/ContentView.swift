//
//  ContentView.swift
//  Resetta
//
//  Created by Wiktor on 15/05/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        AppRootView()
    }
}

#Preview {
    ContentView()
        .environment(SessionTimerService())
        .environment(SessionStorageService())
        .modelContainer(for: DetoxSession.self, inMemory: true)
}
