import SwiftUI
import UIKit

@MainActor
final class OrientationService {
    static let shared = OrientationService()

    private(set) var supportedOrientations = OrientationScope.portraitOnly.supportedOrientations

    private init() {}

    func allowSessionOrientations() {
        apply(.activeSession)
    }

    func lockPortrait() {
        apply(.portraitOnly)
    }

    private func apply(_ scope: OrientationScope) {
        supportedOrientations = scope.supportedOrientations
        updateWindowScenes(requestedOrientations: scope.requestedOrientations)
    }

    private func updateWindowScenes(requestedOrientations: UIInterfaceOrientationMask?) {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .forEach { windowScene in
                windowScene.visibleViewControllers.forEach {
                    $0.setNeedsUpdateOfSupportedInterfaceOrientations()
                }

                if let requestedOrientations {
                    windowScene.requestGeometryUpdate(
                        .iOS(interfaceOrientations: requestedOrientations)
                    )
                }
            }
    }
}

extension View {
    func activeSessionOrientationScope() -> some View {
        modifier(ActiveSessionOrientationModifier())
    }

    func portraitOnlyOrientationScope() -> some View {
        modifier(PortraitOnlyOrientationModifier())
    }
}

private enum OrientationScope {
    case portraitOnly
    case activeSession

    var supportedOrientations: UIInterfaceOrientationMask {
        switch self {
        case .portraitOnly:
            return .portrait
        case .activeSession:
            return [.portrait, .landscapeLeft, .landscapeRight]
        }
    }

    var requestedOrientations: UIInterfaceOrientationMask? {
        switch self {
        case .portraitOnly:
            return .portrait
        case .activeSession:
            return nil
        }
    }
}

private struct ActiveSessionOrientationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                OrientationService.shared.allowSessionOrientations()
            }
            .onDisappear {
                OrientationService.shared.lockPortrait()
            }
    }
}

private struct PortraitOnlyOrientationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                OrientationService.shared.lockPortrait()
            }
    }
}

private extension UIWindowScene {
    var visibleViewControllers: [UIViewController] {
        windows.compactMap(\.rootViewController).flatMap(\.visibleViewControllerTree)
    }
}

private extension UIViewController {
    var visibleViewControllerTree: [UIViewController] {
        var viewControllers = [self]

        if let presentedViewController {
            viewControllers.append(contentsOf: presentedViewController.visibleViewControllerTree)
        }

        for child in children {
            viewControllers.append(contentsOf: child.visibleViewControllerTree)
        }

        return viewControllers
    }
}
