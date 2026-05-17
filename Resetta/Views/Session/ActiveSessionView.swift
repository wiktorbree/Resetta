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
    @State private var hasFinished = false
    @State private var hideEndButtonTask: Task<Void, Never>?
    @State private var showEndButton = false
    @State private var showEndConfirmation = false
    @State private var tickerTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            ResettaTheme.activeBackground(pureBlack: pureBlackModeEnabled)
                .ignoresSafeArea()

            GeometryReader { proxy in
                let availableFontSize = max(CGFloat(52), min(proxy.size.width * 0.26, proxy.size.height * 0.42))
                let resolvedFontSize = min(timerFontSize, availableFontSize)

                Text(TimeFormatting.countdown(timer.remainingTime))
                    .font(.system(size: resolvedFontSize, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.92))
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)
                    .accessibilityLabel(TimeFormatting.accessibleCountdown(timer.remainingTime))
                    .accessibilityAddTraits(.updatesFrequently)
                    .accessibilityHint("Shows the end session control")
                    .accessibilityAction(named: Text("Show End Session Button")) {
                        revealEndButton()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 32)
            }

            VStack {
                Spacer()

                if showEndButton && !showEndConfirmation {
                    Button(action: handleEndButtonTapped) {
                        Text("End Session")
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 20)
                            .frame(minHeight: 44)
                            .background(.white.opacity(0.08), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white.opacity(0.74))
                    .transition(.opacity)
                    .accessibilityHint(endConfirmationEnabled ? "Shows a confirmation before ending the session" : "Ends the session")
                }
            }
            .padding(.bottom, 50)

            if showEndConfirmation {
                Color.black.opacity(0.38)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
                    .onTapGesture {
                        continueSession()
                    }

                EndSessionConfirmationView(
                    onContinue: continueSession,
                    onEnd: endSession
                )
                .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !showEndConfirmation else { return }
            revealEndButton()
        }
        .statusBarHidden(true)
        .onAppear {
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
