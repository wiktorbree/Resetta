import SwiftUI
import UIKit

struct ActiveSessionView: View {
    let onCompleted: () -> Void
    let onEnded: () -> Void

    @AppStorage(UserSettings.StorageKey.endConfirmationEnabled) private var endConfirmationEnabled = UserSettings.defaults.endConfirmationEnabled
    @AppStorage(UserSettings.StorageKey.hapticsEnabled) private var hapticsEnabled = UserSettings.defaults.hapticsEnabled
    @AppStorage(UserSettings.StorageKey.keepScreenAwake) private var keepScreenAwake = UserSettings.defaults.keepScreenAwake
    @AppStorage(UserSettings.StorageKey.pureBlackModeEnabled) private var pureBlackModeEnabled = UserSettings.defaults.pureBlackModeEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @Environment(SessionTimerService.self) private var timer
    @ScaledMetric(relativeTo: .largeTitle) private var timerFontSize: CGFloat = 86
    @State private var hasAppeared = false
    @State private var hasFinished = false
    @State private var hideEndButtonTask: Task<Void, Never>?
    @State private var showEndButton = false
    @State private var showEndConfirmation = false
    @State private var tickerTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            sessionBackground
                .ignoresSafeArea()

            GeometryReader { proxy in
                let isLandscape = proxy.size.width > proxy.size.height
                let resolvedFontSize = timerFontSize(for: proxy.size)

                ZStack {
                    Text(TimeFormatting.countdown(timer.remainingTime))
                        .font(.system(size: resolvedFontSize, weight: .regular, design: .monospaced))
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(showEndConfirmation ? 0.34 : 0.92))
                        .lineLimit(1)
                        .minimumScaleFactor(0.46)
                        .contentTransition(.numericText())
                        .accessibilityLabel(TimeFormatting.accessibleCountdown(timer.remainingTime))
                        .accessibilityAddTraits(.updatesFrequently)
                        .accessibilityHint("Shows the end session control")
                        .accessibilityAction(named: Text("Show End Session Button")) {
                            revealEndButton()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, isLandscape ? 72 : 32)
                        .offset(y: isLandscape ? -6 : -10)
                        .opacity(hasAppeared ? 1 : 0)
                        .animation(motionAnimation(duration: 0.32), value: showEndConfirmation)

                    VStack {
                        Spacer()

                        if showEndButton && !showEndConfirmation {
                            endSessionButton
                                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        }
                    }
                    .padding(.bottom, bottomButtonPadding(proxy: proxy, isLandscape: isLandscape))

                    if showEndConfirmation {
                        Color.black.opacity(0.42)
                            .ignoresSafeArea()
                            .accessibilityHidden(true)
                            .onTapGesture {
                                continueSession()
                            }
                            .transition(.opacity)

                        EndSessionConfirmationView(
                            onContinue: continueSession,
                            onEnd: endSession
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.985)))
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !showEndConfirmation else { return }
            revealEndButton()
        }
        .statusBarHidden(true)
        .onAppear {
            withAnimation(motionAnimation(duration: 0.5)) {
                hasAppeared = true
            }
            resumeTimer()
        }
        .onDisappear {
            cleanup()
        }
        .activeSessionOrientationScope()
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                resumeTimer()
            case .inactive, .background:
                pauseTicker()
            @unknown default:
                break
            }
        }
    }

    @ViewBuilder
    private var sessionBackground: some View {
        if pureBlackModeEnabled {
            Color.black
        } else {
            ZStack {
                ResettaTheme.activeBackground(pureBlack: false)

                LinearGradient(
                    colors: [
                        Color.white.opacity(0.035),
                        Color.clear,
                        Color.black.opacity(0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .accessibilityHidden(true)
            }
        }
    }

    private var endSessionButton: some View {
        Button(action: handleEndButtonTapped) {
            Text("End Session")
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 22)
                .frame(minWidth: 154)
                .frame(minHeight: 52)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white.opacity(0.72))
        .background(.white.opacity(0.045), in: Capsule())
        .glassEffect(.regular.tint(.white.opacity(0.05)).interactive(), in: Capsule())
        .accessibilityHint(endConfirmationEnabled ? "Shows a confirmation before ending the session" : "Ends the session")
    }

    private func timerFontSize(for size: CGSize) -> CGFloat {
        let isLandscape = size.width > size.height
        let widthScale = isLandscape ? size.width * 0.17 : size.width * 0.26
        let heightScale = isLandscape ? size.height * 0.54 : size.height * 0.42
        let availableFontSize = max(CGFloat(52), min(widthScale, heightScale))
        let preferredFontSize = isLandscape ? timerFontSize * 1.28 : timerFontSize

        return min(preferredFontSize, availableFontSize)
    }

    private func bottomButtonPadding(proxy: GeometryProxy, isLandscape: Bool) -> CGFloat {
        if isLandscape {
            return max(22, proxy.safeAreaInsets.bottom + 16)
        }

        return max(50, proxy.safeAreaInsets.bottom + 34)
    }

    private func resumeTimer() {
        UIApplication.shared.isIdleTimerDisabled = keepScreenAwake
        guard updateTimer() else { return }
        startTicker()
    }

    private func startTicker() {
        tickerTask?.cancel()
        guard !hasFinished else { return }

        tickerTask = Task { @MainActor in
            while !Task.isCancelled {
                guard updateTimer() else { return }
                try? await Task.sleep(for: .milliseconds(250))
            }
        }
    }

    @discardableResult
    private func updateTimer(now: Date = Date()) -> Bool {
        timer.refresh(now: now)

        if timer.isActive && timer.hasEnded(at: now) {
            completeSession()
            return false
        }

        return !hasFinished
    }

    private func pauseTicker() {
        tickerTask?.cancel()
        tickerTask = nil
    }

    private func revealEndButton() {
        guard updateTimer() else { return }
        if !showEndButton {
            HapticsService.endSessionButtonRevealed(enabled: hapticsEnabled)
        }

        withAnimation(motionAnimation(duration: 0.22)) {
            showEndButton = true
        }

        hideEndButtonTask?.cancel()
        hideEndButtonTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(5))
            guard !Task.isCancelled else { return }
            hideEndButton()
        }
    }

    private func hideEndButton() {
        withAnimation(motionAnimation(duration: 0.26)) {
            showEndButton = false
        }
    }

    private func handleEndButtonTapped() {
        guard updateTimer() else { return }
        hideEndButtonTask?.cancel()
        hideEndButtonTask = nil

        guard endConfirmationEnabled else {
            endSession()
            return
        }

        withAnimation(motionAnimation(duration: 0.2)) {
            showEndButton = false
            showEndConfirmation = true
        }
    }

    private func continueSession() {
        guard updateTimer() else { return }
        hideEndButtonTask?.cancel()
        hideEndButtonTask = nil

        withAnimation(motionAnimation(duration: 0.2)) {
            showEndConfirmation = false
            showEndButton = false
        }
    }

    private func motionAnimation(duration: Double) -> Animation? {
        reduceMotion ? nil : .easeInOut(duration: duration)
    }

    private func completeSession() {
        guard !hasFinished else { return }
        hasFinished = true
        cleanup()
        onCompleted()
    }

    private func endSession() {
        guard !hasFinished else { return }
        hasFinished = true
        cleanup()
        onEnded()
    }

    private func cleanup() {
        UIApplication.shared.isIdleTimerDisabled = false
        pauseTicker()
        hideEndButtonTask?.cancel()
        hideEndButtonTask = nil
    }
}

#Preview {
    ActiveSessionView(onCompleted: {}, onEnded: {})
        .environment(ActiveSessionPreview.timer)
}

private enum ActiveSessionPreview {
    @MainActor
    static var timer: SessionTimerService {
        let timer = SessionTimerService()
        timer.start(duration: 5 * 60, intent: nil)
        return timer
    }
}
