import UIKit

@MainActor
final class IdleTimerManager {
    static let shared = IdleTimerManager()

    private static let defaultIdleTimeout: TimeInterval = 600 // 10 minutes
    private let idleTimeout: TimeInterval
    private let isTesting: Bool

    private(set) var idleTimer: Timer?
    private var lastInteractionDate = Date()
    private let throttleInterval: TimeInterval

    private(set) var isIdleTimerDisabledValue: Bool = true {
        didSet {
            if !isTesting {
                UIApplication.shared.isIdleTimerDisabled = isIdleTimerDisabledValue
            }
        }
    }

    private var isPluggedIn: Bool = false

    // Production init
    private init() {
        self.idleTimeout = Self.defaultIdleTimeout
        self.throttleInterval = 1.0
        self.isTesting = false
        setupBatteryMonitoring()
    }

    // Testing init
    init(forTesting: Bool, idleTimeout: TimeInterval = 600, throttleInterval: TimeInterval = 1.0) {
        self.idleTimeout = idleTimeout
        self.throttleInterval = throttleInterval
        self.isTesting = forTesting
    }

    private func setupBatteryMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateDidChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
        // Apply initial state
        handleBatteryStateChange(to: UIDevice.current.batteryState)
    }

    @objc private func batteryStateDidChange() {
        handleBatteryStateChange(to: UIDevice.current.batteryState)
    }

    func handleBatteryStateChange(to state: UIDevice.BatteryState) {
        switch state {
        case .charging, .full:
            isPluggedIn = true
            idleTimer?.invalidate()
            idleTimer = nil
            isIdleTimerDisabledValue = true
        case .unplugged:
            isPluggedIn = false
            isIdleTimerDisabledValue = true
            startIdleTimer()
        case .unknown:
            // Treat unknown as plugged in (safe default)
            isPluggedIn = true
            idleTimer?.invalidate()
            idleTimer = nil
            isIdleTimerDisabledValue = true
        @unknown default:
            break
        }
    }

    func userInteracted() {
        guard !isPluggedIn else { return }

        let now = Date()
        guard now.timeIntervalSince(lastInteractionDate) >= throttleInterval else { return }
        lastInteractionDate = now

        isIdleTimerDisabledValue = true
        startIdleTimer()
    }

    private func startIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: idleTimeout, repeats: false) { [weak self] _ in
            self?.isIdleTimerDisabledValue = false
        }
    }
}
