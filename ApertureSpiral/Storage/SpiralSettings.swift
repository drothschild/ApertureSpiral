import Foundation
import Combine

class SpiralSettings: ObservableObject {
    static let shared = SpiralSettings()

    // UserDefaults keys
    private enum Keys {
        static let bladeCount = "spiral.bladeCount"
        static let layerCount = "spiral.layerCount"
        static let speed = "spiral.speed"
        static let apertureSize = "spiral.apertureSize"
        static let phrases = "spiral.phrases"
        static let captureTimerMinutes = "spiral.captureTimerMinutes"
        static let previewOnly = "spiral.previewOnly"
        static let colorFlowSpeed = "spiral.colorFlowSpeed"
        static let mirrorAlwaysOn = "spiral.mirrorAlwaysOn"
        static let mirrorAnimationMode = "spiral.mirrorAnimationMode"
        static let eyeCenteringEnabled = "spiral.eyeCenteringEnabled"
        static let colorPaletteId = "spiral.colorPaletteId"
        static let hasLaunchedBefore = "spiral.hasLaunchedBefore"
    }

    // Default values
    private enum Defaults {
        static let bladeCount = 9
        static let layerCount = 5
        static let speed = 1.0
        static let apertureSize = 0.5
        static let phrases = ["Happy", "Birthday", "We Love You"]
        static let captureTimerMinutes = 0
        static let previewOnly = true
        static let colorFlowSpeed = 0.3
        static let mirrorAlwaysOn = true
        // 1 = Zoom only, 2 = Zoom + Scale
        static let mirrorAnimationMode = 2
        static let eyeCenteringEnabled = true
        static let colorPaletteId = "warm"
    }

    @Published var bladeCount: Int = Defaults.bladeCount {
        didSet { userDefaults.set(bladeCount, forKey: Keys.bladeCount) }
    }
    @Published var layerCount: Int = Defaults.layerCount {
        didSet { userDefaults.set(layerCount, forKey: Keys.layerCount) }
    }
    @Published var speed: Double = Defaults.speed {
        didSet { userDefaults.set(speed, forKey: Keys.speed) }
    }
    @Published var apertureSize: Double = Defaults.apertureSize {
        didSet { userDefaults.set(apertureSize, forKey: Keys.apertureSize) }
    }
    @Published var phrases: [String] = Defaults.phrases {
        didSet { userDefaults.set(phrases, forKey: Keys.phrases) }
    }
    @Published var captureTimerMinutes: Int = Defaults.captureTimerMinutes {
        didSet { userDefaults.set(captureTimerMinutes, forKey: Keys.captureTimerMinutes) }
    }
    @Published var previewOnly: Bool = Defaults.previewOnly {  // Show camera preview without capturing
        didSet { userDefaults.set(previewOnly, forKey: Keys.previewOnly) }
    }
    @Published var colorFlowSpeed: Double = Defaults.colorFlowSpeed {  // Speed of color flow from inside to outside
        didSet { userDefaults.set(colorFlowSpeed, forKey: Keys.colorFlowSpeed) }
    }
    @Published var mirrorAlwaysOn: Bool = Defaults.mirrorAlwaysOn {  // Keep camera preview always visible
        didSet { userDefaults.set(mirrorAlwaysOn, forKey: Keys.mirrorAlwaysOn) }
    }
    @Published var mirrorAnimationMode: Int = Defaults.mirrorAnimationMode {  // 1 = Zoom only, 2 = Zoom + Scale
        didSet { userDefaults.set(mirrorAnimationMode, forKey: Keys.mirrorAnimationMode) }
    }
    @Published var eyeCenteringEnabled: Bool = Defaults.eyeCenteringEnabled {  // Use AI to center camera on user's eyes
        didSet { userDefaults.set(eyeCenteringEnabled, forKey: Keys.eyeCenteringEnabled) }
    }
    @Published var colorPaletteId: String = Defaults.colorPaletteId {
        didSet { userDefaults.set(colorPaletteId, forKey: Keys.colorPaletteId) }
    }

    var colorPalette: ColorPalette {
        ColorPalette.find(id: colorPaletteId) ?? .default
    }

    private let userDefaults: UserDefaults

    private init() {
        self.userDefaults = .standard

        // Load saved values or use defaults
        let hasLaunchedBefore = userDefaults.bool(forKey: Keys.hasLaunchedBefore)

        if hasLaunchedBefore {
            bladeCount = userDefaults.integer(forKey: Keys.bladeCount)
            layerCount = userDefaults.integer(forKey: Keys.layerCount)
            speed = userDefaults.double(forKey: Keys.speed)
            apertureSize = userDefaults.double(forKey: Keys.apertureSize)
            phrases = userDefaults.stringArray(forKey: Keys.phrases) ?? Defaults.phrases
            captureTimerMinutes = userDefaults.integer(forKey: Keys.captureTimerMinutes)
            previewOnly = userDefaults.bool(forKey: Keys.previewOnly)
            colorFlowSpeed = userDefaults.double(forKey: Keys.colorFlowSpeed)
            mirrorAlwaysOn = userDefaults.bool(forKey: Keys.mirrorAlwaysOn)
            mirrorAnimationMode = userDefaults.integer(forKey: Keys.mirrorAnimationMode)
            // Normalize legacy value 0 -> 1
            if mirrorAnimationMode == 0 {
                mirrorAnimationMode = 1
            }
            // Eye centering defaults to true if not set
            eyeCenteringEnabled = userDefaults.object(forKey: Keys.eyeCenteringEnabled) == nil ? Defaults.eyeCenteringEnabled : userDefaults.bool(forKey: Keys.eyeCenteringEnabled)
            colorPaletteId = userDefaults.string(forKey: Keys.colorPaletteId) ?? Defaults.colorPaletteId

            // Handle zero values that might indicate unset (use defaults instead)
            if bladeCount == 0 { bladeCount = Defaults.bladeCount }
            if layerCount == 0 { layerCount = Defaults.layerCount }
            if speed == 0 { speed = Defaults.speed }
            if apertureSize == 0 { apertureSize = Defaults.apertureSize }
            if colorFlowSpeed == 0 { colorFlowSpeed = Defaults.colorFlowSpeed }
        } else {
            // First launch - use defaults
            bladeCount = Defaults.bladeCount
            layerCount = Defaults.layerCount
            speed = Defaults.speed
            apertureSize = Defaults.apertureSize
            phrases = Defaults.phrases
            captureTimerMinutes = Defaults.captureTimerMinutes
            previewOnly = Defaults.previewOnly
            colorFlowSpeed = Defaults.colorFlowSpeed
            mirrorAlwaysOn = Defaults.mirrorAlwaysOn
            mirrorAnimationMode = Defaults.mirrorAnimationMode
            eyeCenteringEnabled = Defaults.eyeCenteringEnabled
            colorPaletteId = Defaults.colorPaletteId

            userDefaults.set(true, forKey: Keys.hasLaunchedBefore)
        }
    }

    /// Creates an instance for testing purposes
    init(forTesting userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        bladeCount = Defaults.bladeCount
        layerCount = Defaults.layerCount
        speed = Defaults.speed
        apertureSize = Defaults.apertureSize
        phrases = Defaults.phrases
        captureTimerMinutes = Defaults.captureTimerMinutes
        previewOnly = Defaults.previewOnly
        colorFlowSpeed = Defaults.colorFlowSpeed
        mirrorAlwaysOn = Defaults.mirrorAlwaysOn
        mirrorAnimationMode = Defaults.mirrorAnimationMode
        eyeCenteringEnabled = Defaults.eyeCenteringEnabled
        colorPaletteId = Defaults.colorPaletteId
    }

    /// Resets all settings to defaults
    func reset() {
        bladeCount = Defaults.bladeCount
        layerCount = Defaults.layerCount
        speed = Defaults.speed
        apertureSize = Defaults.apertureSize
        phrases = Defaults.phrases
        captureTimerMinutes = Defaults.captureTimerMinutes
        previewOnly = Defaults.previewOnly
        colorFlowSpeed = Defaults.colorFlowSpeed
        mirrorAlwaysOn = Defaults.mirrorAlwaysOn
        mirrorAnimationMode = Defaults.mirrorAnimationMode
        eyeCenteringEnabled = Defaults.eyeCenteringEnabled
        colorPaletteId = Defaults.colorPaletteId
    }

    var phrasesText: String {
        get { phrases.joined(separator: "\n") }
        set { phrases = newValue.split(separator: "\n").map { String($0) }.filter { !$0.isEmpty } }
    }
}
