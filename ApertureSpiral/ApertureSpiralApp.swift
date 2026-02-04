import SwiftUI

@main
struct ApertureSpiralApp: App {
    var body: some Scene {
        WindowGroup {
            KeyCommandView {
                MainView()
            }
            .preferredColorScheme(.dark)
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
        // Allow key commands to work without showing in menu
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
            // Handle arrow keys
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
        SpiralSettings.shared.mirrorAlwaysOn.toggle()
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
