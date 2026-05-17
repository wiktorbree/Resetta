import SwiftUI
import SwiftData

struct HomeView: View {
    @AppStorage(UserSettings.StorageKey.hapticsEnabled) private var hapticsEnabled = UserSettings.defaults.hapticsEnabled
    @ScaledMetric(relativeTo: .largeTitle) private var selectedDurationFontSize: CGFloat = 72
    @State private var selectedMinutes = 5
    @State private var pendingDuration: DurationSelection?

    private let presets = [5, 15, 30, 60]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Text("Ready to disconnect?")
                            .font(.title.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(selectedMinutes)")
                            .font(.system(size: selectedDurationFontSize, weight: .semibold, design: .rounded).monospacedDigit())
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .accessibilityLabel("\(selectedMinutes) minutes selected")

                        Text(selectedMinutes == 1 ? "minute" : "minutes")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(presets, id: \.self) { minutes in
                            DurationPresetView(
                                minutes: minutes,
                                isSelected: selectedMinutes == minutes
                            ) {
                                selectedMinutes = minutes
                                HapticsService.selection(enabled: hapticsEnabled)
                            }
                        }
                    }

                    Spacer(minLength: 24)

                    VStack(spacing: 12) {
                        Button {
                            pendingDuration = DurationSelection(duration: TimeInterval(selectedMinutes * 60))
                            HapticsService.lightImpact(enabled: hapticsEnabled)
                        } label: {
                            Text("Start Detox")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 54)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(ResettaTheme.accent)
                        .controlSize(.large)

                        Text("Sit with the boredom.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(24)
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
        }
        .navigationTitle("Resetta")
        .navigationBarTitleDisplayMode(.inline)
        .portraitOnlyOrientationScope()
        .fullScreenCover(item: $pendingDuration) { selection in
            SessionFlowView(duration: selection.duration)
        }
    }
}

private struct DurationSelection: Identifiable {
    let id = UUID()
    let duration: TimeInterval
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(SessionTimerService())
    .environment(SessionStorageService())
    .modelContainer(for: DetoxSession.self, inMemory: true)
}
