import UIKit

final class OrientationService {
    static let shared = OrientationService()

    private(set) var supportedOrientations: UIInterfaceOrientationMask = .portrait

    private init() {}

    func allowSessionOrientations() {
        supportedOrientations = [.portrait, .landscapeLeft, .landscapeRight]
        updateWindowScenes(requestedOrientations: nil)
    }

    func lockPortrait() {
        supportedOrientations = .portrait
        updateWindowScenes(requestedOrientations: .portrait)
    }

    private func updateWindowScenes(requestedOrientations: UIInterfaceOrientationMask?) {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .forEach { windowScene in
                windowScene.windows
                    .first(where: \.isKeyWindow)?
                    .rootViewController?
                    .setNeedsUpdateOfSupportedInterfaceOrientations()

                if let requestedOrientations {
                    windowScene.requestGeometryUpdate(
                        .iOS(interfaceOrientations: requestedOrientations)
                    )
                }
            }
    }
}
