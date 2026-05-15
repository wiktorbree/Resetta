import SwiftUI
import UIKit

struct ActiveSessionView: View {
    let onCompleted: () -> Void
    let onEnded: () -> Void

    @AppStorage("hapticsEnabled") private var hapticsEnabled = UserSettings.defaults.hapticsEnabled
    @AppStorage("keepScreenAwake") private var keepScreenAwake = UserSettings.defaults.keepScreenAwake
    @AppStorage("pureBlackModeEnabled") private var pureBlackModeEnabled = UserSettings.defaults.pureBlackModeEnabled
    @Environment(\.scenePhase) private var scenePhase
    @Environment(SessionTimerService.self) private var timer
    @State private var hasFinished = false
    @State private var hideEndButtonTask: Task<Void, Never>?
    @State private var showEndButton = false
    @State private var showEndConfirmation = false
    @State private var tickerTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            ResettaTheme.activeBackground(pureBlack: pureBlackModeEnabled)
                .ignoresSafeArea()

            Text(TimeFormatting.countdown(timer.remainingTime))
                .font(.system(size: 92, weight: .semibold, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.42)
                .accessibilityLabel("\(TimeFormatting.countdown(timer.remainingTime)) remaining")
                .padding(.horizontal, 28)

            VStack {
                Spacer()

                if showEndButton && !showEndConfirmation {
                    Button(action: handleEndButtonTapped) {
                        Text("End Session")
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .frame(height: 48)
                            .background(.white.opacity(0.11), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white.opacity(0.82))
                    .transition(.opacity)
                    .accessibilityHint("Shows a confirmation before ending the session")
                }
            }
            .padding(.bottom, 52)

            if showEndConfirmation {
                Color.black.opacity(0.42)
                    .ignoresSafeArea()
                    .onTapGesture {
                        continueSession()
                    }

                EndSessionConfirmationView(
                    onContinue: continueSession,
                    onEnd: endSession
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
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
        HapticsService.lightImpact(enabled: hapticsEnabled)

        withAnimation(.easeInOut(duration: 0.18)) {
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
        withAnimation(.easeInOut(duration: 0.24)) {
            showEndButton = false
        }
    }

    private func handleEndButtonTapped() {
        guard updateTimer() else { return }
        HapticsService.lightImpact(enabled: hapticsEnabled)
        hideEndButtonTask?.cancel()
        hideEndButtonTask = nil

        withAnimation(.easeInOut(duration: 0.2)) {
            showEndButton = false
            showEndConfirmation = true
        }
    }

    private func continueSession() {
        guard updateTimer() else { return }
        hideEndButtonTask?.cancel()
        hideEndButtonTask = nil

        withAnimation(.easeInOut(duration: 0.2)) {
            showEndConfirmation = false
            showEndButton = false
        }
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
    let timer = SessionTimerService()
    timer.start(duration: 5 * 60, intent: nil)

    return ActiveSessionView(onCompleted: {}, onEnded: {})
        .environment(timer)
}
