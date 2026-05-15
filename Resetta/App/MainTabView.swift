import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    tab.content
                }
                .tabItem {
                    tab.label
                }
                .tag(tab)
            }
        }
        .tint(ResettaTheme.accent)
        .onAppear {
            OrientationService.shared.lockPortrait()
        }
    }
}

private enum AppTab: Hashable, CaseIterable, Identifiable {
    case home
    case history
    case settings

    var id: Self { self }

    @ViewBuilder
    var content: some View {
        switch self {
        case .home:
            HomeView()
        case .history:
            HistoryView()
        case .settings:
            SettingsView()
        }
    }

    @ViewBuilder
    var label: some View {
        switch self {
        case .home:
            Label("Home", systemImage: "house")
        case .history:
            Label("History", systemImage: "clock.arrow.circlepath")
        case .settings:
            Label("Settings", systemImage: "gearshape")
        }
    }
}

#Preview {
    MainTabView()
        .environment(SessionTimerService())
        .environment(SessionStorageService())
        .modelContainer(for: DetoxSession.self, inMemory: true)
}
