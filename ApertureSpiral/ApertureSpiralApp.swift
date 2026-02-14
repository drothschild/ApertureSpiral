import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = IdleTrackingWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView:
            KeyCommandView {
                MainView()
            }
            .preferredColorScheme(.dark)
        )
        self.window = window
        window.makeKeyAndVisible()
    }
}

class IdleTrackingWindow: UIWindow {
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        if event.type == .touches {
            MainActor.assumeIsolated {
                IdleTimerManager.shared.userInteracted()
            }
        }
    }
}

@main
struct ApertureSpiralApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            // Content is managed by SceneDelegate's IdleTrackingWindow
            EmptyView()
        }
    }
}

// A UIViewControllerRepresentable that adds key command support
struct KeyCommandView<Content: View>: UIViewControllerRepresentable {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIViewController(context: Context) -> KeyCommandViewController<Content> {
        KeyCommandViewController(rootView: content)
    }

    func updateUIViewController(_ uiViewController: KeyCommandViewController<Content>, context: Context) {
        uiViewController.rootView = content
    }
}

class KeyCommandViewController<Content: View>: UIHostingController<Content> {
    override var keyCommands: [UIKeyCommand]? {
        let commands = [
            UIKeyCommand(input: "m", modifierFlags: [], action: #selector(toggleMirror)),
            UIKeyCommand(input: "r", modifierFlags: [], action: #selector(randomizeSettings)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(speedUp)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(slowDown))
        ]
        commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
        return commands
    }

    override var canBecomeFirstResponder: Bool { true }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var didHandleEvent = false
        for press in presses {
            guard let key = press.key else { continue }
            switch key.charactersIgnoringModifiers {
            case "r":
                randomizeSettings()
                didHandleEvent = true
            case "m":
                toggleMirror()
                didHandleEvent = true
            default:
                break
            }
            switch key.keyCode {
            case .keyboardRightArrow:
                speedUp()
                didHandleEvent = true
            case .keyboardLeftArrow:
                slowDown()
                didHandleEvent = true
            default:
                break
            }
        }
        if !didHandleEvent {
            super.pressesBegan(presses, with: event)
        }
    }

    @objc func toggleMirror() {
        let settings = SpiralSettings.shared
        if settings.spiralCenterMode == .mirror {
            settings.spiralCenterMode = .none
        } else {
            settings.spiralCenterMode = .mirror
        }
    }

    @objc func randomizeSettings() {
        SpiralSettings.shared.randomize()
        NotificationCenter.default.post(name: .showRandomizeFlash, object: nil)
    }

    @objc func speedUp() {
        SpiralSettings.shared.speed = min(3.0, SpiralSettings.shared.speed + 0.4)
        NotificationCenter.default.post(name: .showSpeedIndicator, object: nil)
    }

    @objc func slowDown() {
        SpiralSettings.shared.speed = max(0.1, SpiralSettings.shared.speed - 0.4)
        NotificationCenter.default.post(name: .showSpeedIndicator, object: nil)
    }
}

extension Notification.Name {
    static let showSpeedIndicator = Notification.Name("showSpeedIndicator")
    static let showRandomizeFlash = Notification.Name("showRandomizeFlash")
}
