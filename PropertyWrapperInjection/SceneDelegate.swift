//
//  SceneDelegate.swift
//  PropertyWrapperInjection
//
//  Created by Nico Ameghino on 25/01/2021.
//

import UIKit

class TimeViewModel {
    @Injected var timeProvider: TimeProviderProtocol

    @Injected(label: "my birthday") var nico: TimeProviderProtocol

    var labelText: String = "* not yet set *"

    func update(nico: Bool = false) {
        if nico {
            self.labelText = "\(self.nico.now)"
        } else {
            self.labelText = "\(self.timeProvider.now)"
        }
    }
}

class UsernamePasswordLoginViewModel {
    @Injected var authenticator: AuthenticatorProtocol

    var username: String!
    var password: String!

    func login(callback: @escaping () -> Void) {
        let credentials = UserCredentials(username: username, password: password)
        authenticator.authenticate(with: credentials) { session in
            guard let session = session else { callback(); return }
            let container = ComponentContainer()
            container.register(type: UserSession.self) { _ in session}

            ComponentContainer.push(container: container)
            callback()
        }
    }
}

class MessagesViewModel {
    @Injected var userSession: UserSession

    func play() {
        print(userSession)
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

        let login = UsernamePasswordLoginViewModel()
        login.username = "nameghino"
        login.password = "secret"

        login.login {
            let messages = MessagesViewModel()
            messages.play()
        }
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
            let mock = MockNetworking()
            mock.register(value: UserSession(username: "nameghino", validUntil: Date().addingTimeInterval(7 * 86400)),
                          for: "/v1/login")
            return mock
        }

        container.register(type: TimeProviderProtocol.self) { _ in Realtime() }
        container.register(type: TimeProviderProtocol.self, label: "my birthday") { _ in
            let components = DateComponents(calendar: .autoupdatingCurrent,
                                            timeZone: TimeZone(secondsFromGMT: -3 * 3600), year: 1986, month: 4, day: 23, hour: 9, minute: 50)
            let date = Calendar.autoupdatingCurrent.date(from: components)!
            return MockTimeProvider(with: date)
        }

        container.register(type: AuthenticatorProtocol.self, scope: .transient) { _ in Authenticator() }

        ComponentContainer.set(root: container)
    }

}

