import SwiftUI
import SwiftData

struct HomeView: View {
    @AppStorage(UserSettings.StorageKey.hapticsEnabled) private var hapticsEnabled = UserSettings.defaults.hapticsEnabled
    @ScaledMetric(relativeTo: .largeTitle) private var selectedDurationFontSize: CGFloat = 72
    @State private var selectedMinutes = 5
    @State private var pendingDuration: DurationSelection?

    private let presets = [5, 15, 30, 60]
    private let columns = [GridItem(.adaptive(minimum: 72), spacing: 12)]

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 34) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)

                        Text("Ready to disconnect?")
                            .font(.largeTitle.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(selectedMinutes)")
                            .font(.system(size: selectedDurationFontSize, weight: .medium, design: .default).monospacedDigit())
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .contentTransition(.numericText(value: Double(selectedMinutes)))
                            .accessibilityLabel("\(selectedMinutes) minutes selected")

                        Text(selectedMinutes == 1 ? "minute" : "minutes")
                            .font(.title3.weight(.regular))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 18)

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(presets, id: \.self) { minutes in
                            DurationPresetView(
                                minutes: minutes,
                                isSelected: selectedMinutes == minutes
                            ) {
                                withAnimation(.easeInOut(duration: 0.18)) {
                                    selectedMinutes = minutes
                                }
                                HapticsService.selection(enabled: hapticsEnabled)
                            }
                        }
                    }

                    Spacer(minLength: 24)

                    VStack(spacing: 14) {
                        Button {
                            pendingDuration = DurationSelection(duration: TimeInterval(selectedMinutes * 60))
                            HapticsService.lightImpact(enabled: hapticsEnabled)
                        } label: {
                            Text("Start Detox")
                        }
                        .buttonStyle(ValePrimaryButtonStyle())

                        Text("Sit with the boredom.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, ValeTheme.horizontalPadding(for: proxy.size.width))
                .padding(.top, 48)
                .padding(.bottom, max(34, proxy.safeAreaInsets.bottom + 24))
                .frame(maxWidth: ValeTheme.contentWidth(for: proxy.size.width), minHeight: proxy.size.height, alignment: .top)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .background(ValeTheme.screenBackground.ignoresSafeArea())
        .navigationTitle("Vale")
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
