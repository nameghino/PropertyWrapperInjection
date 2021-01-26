//
//  SceneDelegate.swift
//  PropertyWrapperInjection
//
//  Created by Nico Ameghino on 25/01/2021.
//

import UIKit

class TimeViewModel {
    @Injected<TimeProviderProtocol>
    var timeProvider

    @Injected<TimeProviderProtocol>(label: "my birthday")
    var nico

    var labelText: String = "* not yet set *"

    func update(nico: Bool = false) {
        if nico {
            self.labelText = "\(self.nico.now)"
        } else {
            self.labelText = "\(self.timeProvider.now)"
        }
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        setupComponents()

        let viewModel = TimeViewModel()
        print(viewModel.labelText)
        viewModel.update()
        print(viewModel.labelText)
        viewModel.update(nico: true)
        print(viewModel.labelText)
        viewModel.update()
        print(viewModel.labelText)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    private func setupComponents() {
        let container = ComponentContainer()
        container.register(type: NetworkingProtocol.self) { _ in
            return URLSession.shared
        }

        container.register(type: TimeProviderProtocol.self) { _ in Realtime() }
        container.register(type: TimeProviderProtocol.self, label: "my birthday") { _ in
            let components = DateComponents(calendar: .autoupdatingCurrent,
                                            timeZone: TimeZone(secondsFromGMT: -3 * 3600), year: 1986, month: 4, day: 23, hour: 9, minute: 50)
            let date = Calendar.autoupdatingCurrent.date(from: components)!
            return MockTimeProvider(with: date)
        }

        ComponentContainer.set(root: container)
    }

}

