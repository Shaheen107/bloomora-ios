import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let store = BloomoraStore()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let navigationController = UINavigationController(rootViewController: BloomoraHomeViewController(store: store))
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.view.backgroundColor = .bloomoraBackground

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.tintColor = .black
        window.overrideUserInterfaceStyle = .light
        window.makeKeyAndVisible()

        self.window = window
    }
}
