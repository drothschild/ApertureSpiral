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
        [
            UIKeyCommand(input: "m", modifierFlags: [], action: #selector(toggleMirror)),
            UIKeyCommand(input: "p", modifierFlags: [], action: #selector(capturePhoto)),
            UIKeyCommand(input: "r", modifierFlags: [], action: #selector(randomizeSettings))
        ]
    }

    override var canBecomeFirstResponder: Bool { true }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    @objc func toggleMirror() {
        SpiralSettings.shared.mirrorAlwaysOn.toggle()
    }

    @objc func capturePhoto() {
        NotificationCenter.default.post(name: .capturePhoto, object: nil)
    }

    @objc func randomizeSettings() {
        SpiralSettings.shared.randomize()
    }
}

extension Notification.Name {
    static let capturePhoto = Notification.Name("capturePhoto")
}
