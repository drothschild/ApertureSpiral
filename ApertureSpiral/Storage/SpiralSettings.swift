import Foundation
import Combine

enum SpiralCenterMode: Int, CaseIterable {
    case none = 0
    case mirror = 1
    case photo = 2

    var displayName: String {
        switch self {
        case .none: return "None"
        case .mirror: return "Mirror"
        case .photo: return "Photo"
        }
    }
}

class SpiralSettings: ObservableObject {
    static let shared = SpiralSettings()

    private var cancellables = Set<AnyCancellable>()

    // UserDefaults keys
    private enum Keys {
        static let bladeCount = "spiral.bladeCount"
        static let layerCount = "spiral.layerCount"
        static let speed = "spiral.speed"
        static let apertureSize = "spiral.apertureSize"
        static let phrases = "spiral.phrases"
        static let phraseDisplayDuration = "spiral.phraseDisplayDuration"
        static let previewOnly = "spiral.previewOnly"
        static let colorFlowSpeed = "spiral.colorFlowSpeed"
        static let mirrorAlwaysOn = "spiral.mirrorAlwaysOn"
        static let mirrorAnimationMode = "spiral.mirrorAnimationMode"
        static let eyeCenteringEnabled = "spiral.eyeCenteringEnabled"
        static let freezeWhenNoFace = "spiral.freezeWhenNoFace"
        static let freezeWhenNotLooking = "spiral.freezeWhenNotLooking"
        static let colorPaletteId = "spiral.colorPaletteId"
        static let colorByBlade = "spiral.colorByBlade"
        static let lensFlareEnabled = "spiral.lensFlareEnabled"
        static let hasLaunchedBefore = "spiral.hasLaunchedBefore"
        static let selectedPhotoData = "spiral.selectedPhotoData"
        static let photoCenterX = "spiral.photoCenterX"
        static let photoCenterY = "spiral.photoCenterY"
        static let spiralCenterModeRaw = "spiral.spiralCenterModeRaw"
    }

    // Default values
    private enum Defaults {
        static let bladeCount = 9
        static let layerCount = 5
        static let speed = 1.0
        static let apertureSize = 0.5
        static let phrases = ["Happy", "Birthday", "We Love You"]
        static let phraseDisplayDuration = 2.0  // Seconds to show each phrase
        static let previewOnly = true
        static let colorFlowSpeed = 0.3
        static let mirrorAlwaysOn = true
        // 1 = Zoom only, 2 = Zoom + Scale
        static let mirrorAnimationMode = 2
        static let eyeCenteringEnabled = true
        static let freezeWhenNoFace = false
        static let freezeWhenNotLooking = false
        static let colorPaletteId = "warm"
        static let colorByBlade = false
        static let lensFlareEnabled = true
        static let photoCenterX = 0.5  // Center of image (normalized 0-1)
        static let photoCenterY = 0.5  // Center of image (normalized 0-1)
    }

    @Published var bladeCount: Int = Defaults.bladeCount {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(bladeCount, forKey: Keys.bladeCount) } }
    }
    @Published var layerCount: Int = Defaults.layerCount {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(layerCount, forKey: Keys.layerCount) } }
    }
    @Published var speed: Double = Defaults.speed {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(speed, forKey: Keys.speed) } }
    }
    @Published var apertureSize: Double = Defaults.apertureSize {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(apertureSize, forKey: Keys.apertureSize) } }
    }
    @Published var phrases: [String] = Defaults.phrases {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(phrases, forKey: Keys.phrases) } }
    }
    @Published var phraseDisplayDuration: Double = Defaults.phraseDisplayDuration {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(phraseDisplayDuration, forKey: Keys.phraseDisplayDuration) } }
    }
    @Published var previewOnly: Bool = Defaults.previewOnly {  // Show camera preview without capturing
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(previewOnly, forKey: Keys.previewOnly) } }
    }
    @Published var colorFlowSpeed: Double = Defaults.colorFlowSpeed {  // Speed of color flow from inside to outside
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(colorFlowSpeed, forKey: Keys.colorFlowSpeed) } }
    }
    @Published var mirrorAlwaysOn: Bool = Defaults.mirrorAlwaysOn {  // Keep camera preview always visible
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(mirrorAlwaysOn, forKey: Keys.mirrorAlwaysOn) } }
    }
    @Published var mirrorAnimationMode: Int = Defaults.mirrorAnimationMode {  // 1 = Zoom only, 2 = Zoom + Scale
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(mirrorAnimationMode, forKey: Keys.mirrorAnimationMode) } }
    }
    @Published var eyeCenteringEnabled: Bool = Defaults.eyeCenteringEnabled {  // Use AI to center camera on user's eyes
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(eyeCenteringEnabled, forKey: Keys.eyeCenteringEnabled) } }
    }
    @Published var freezeWhenNoFace: Bool = Defaults.freezeWhenNoFace {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(freezeWhenNoFace, forKey: Keys.freezeWhenNoFace) } }
    }
    @Published var freezeWhenNotLooking: Bool = Defaults.freezeWhenNotLooking {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(freezeWhenNotLooking, forKey: Keys.freezeWhenNotLooking) } }
    }
    // Runtime flag controlled by CameraManager when face is lost or not looking
    @Published var spiralFrozen: Bool = false {
        didSet {
            AudioSessionManager.shared.handleSpiralFrozenChange(isFrozen: spiralFrozen)
        }
    }
    @Published var colorPaletteId: String = Defaults.colorPaletteId {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(colorPaletteId, forKey: Keys.colorPaletteId) } }
    }
    @Published var colorByBlade: Bool = Defaults.colorByBlade {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(colorByBlade, forKey: Keys.colorByBlade) } }
    }
    @Published var lensFlareEnabled: Bool = Defaults.lensFlareEnabled {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(lensFlareEnabled, forKey: Keys.lensFlareEnabled) } }
    }
    @Published var selectedPhotoData: Data? = nil {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(selectedPhotoData, forKey: Keys.selectedPhotoData) } }
    }
    @Published var photoCenterX: Double = Defaults.photoCenterX {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(photoCenterX, forKey: Keys.photoCenterX) } }
    }
    @Published var photoCenterY: Double = Defaults.photoCenterY {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(photoCenterY, forKey: Keys.photoCenterY) } }
    }

    /// Raw stored value for spiral center mode (0=none, 1=mirror, 2=photo)
    @Published var spiralCenterModeRaw: Int = SpiralCenterMode.mirror.rawValue {
        didSet { if !suppressUserDefaultsWrites { userDefaults.set(spiralCenterModeRaw, forKey: Keys.spiralCenterModeRaw) } }
    }

    /// Computed property for the spiral center mode
    var spiralCenterMode: SpiralCenterMode {
        get {
            SpiralCenterMode(rawValue: spiralCenterModeRaw) ?? .mirror
        }
        set {
            spiralCenterModeRaw = newValue.rawValue
            // Update mirrorAlwaysOn to match mode for compatibility
            mirrorAlwaysOn = (newValue == .mirror)
            // Always use scale-only mode for mirror (frame shrinks with aperture)
            if newValue == .mirror {
                mirrorAnimationMode = 0
            }
        }
    }

    // When true, property setters will not write to UserDefaults immediately.
    private var suppressUserDefaultsWrites: Bool = false

    /// Apply all values from a preset in a single batch to avoid many UserDefaults writes.
    func applyPreset(_ preset: Preset) {
        suppressUserDefaultsWrites = true
        bladeCount = preset.bladeCount
        layerCount = preset.layerCount
        speed = preset.speed
        apertureSize = preset.apertureSize
        phrases = preset.phrases
        phraseDisplayDuration = preset.phraseDisplayDuration
        previewOnly = preset.previewOnly
        colorFlowSpeed = preset.colorFlowSpeed
        mirrorAlwaysOn = preset.mirrorAlwaysOn
        mirrorAnimationMode = (preset.mirrorAnimationMode == 0 ? 1 : preset.mirrorAnimationMode)
        eyeCenteringEnabled = preset.eyeCenteringEnabled
        freezeWhenNoFace = preset.freezeWhenNoFace
        freezeWhenNotLooking = preset.freezeWhenNotLooking
        colorPaletteId = preset.colorPaletteId
        colorByBlade = preset.colorByBlade
        lensFlareEnabled = preset.lensFlareEnabled
        suppressUserDefaultsWrites = false
        // Persist all values once
        persistAllToUserDefaults()
    }

    private func persistAllToUserDefaults() {
        // Snapshot values and persist off the main thread to avoid blocking UI.
        let snapshot = (
            bladeCount: bladeCount,
            layerCount: layerCount,
            speed: speed,
            apertureSize: apertureSize,
            phrases: phrases,
            phraseDisplayDuration: phraseDisplayDuration,
            previewOnly: previewOnly,
            colorFlowSpeed: colorFlowSpeed,
            mirrorAlwaysOn: mirrorAlwaysOn,
            mirrorAnimationMode: mirrorAnimationMode,
            eyeCenteringEnabled: eyeCenteringEnabled,
            freezeWhenNoFace: freezeWhenNoFace,
            freezeWhenNotLooking: freezeWhenNotLooking,
            colorPaletteId: colorPaletteId,
            colorByBlade: colorByBlade,
            lensFlareEnabled: lensFlareEnabled
        )

        DispatchQueue.global(qos: .userInitiated).async {
            let ud = self.userDefaults
            ud.set(snapshot.bladeCount, forKey: Keys.bladeCount)
            ud.set(snapshot.layerCount, forKey: Keys.layerCount)
            ud.set(snapshot.speed, forKey: Keys.speed)
            ud.set(snapshot.apertureSize, forKey: Keys.apertureSize)
            ud.set(snapshot.phrases, forKey: Keys.phrases)
            ud.set(snapshot.phraseDisplayDuration, forKey: Keys.phraseDisplayDuration)
            ud.set(snapshot.previewOnly, forKey: Keys.previewOnly)
            ud.set(snapshot.colorFlowSpeed, forKey: Keys.colorFlowSpeed)
            ud.set(snapshot.mirrorAlwaysOn, forKey: Keys.mirrorAlwaysOn)
            ud.set(snapshot.mirrorAnimationMode, forKey: Keys.mirrorAnimationMode)
            ud.set(snapshot.eyeCenteringEnabled, forKey: Keys.eyeCenteringEnabled)
            ud.set(snapshot.freezeWhenNoFace, forKey: Keys.freezeWhenNoFace)
            ud.set(snapshot.freezeWhenNotLooking, forKey: Keys.freezeWhenNotLooking)
            ud.set(snapshot.colorPaletteId, forKey: Keys.colorPaletteId)
            ud.set(snapshot.colorByBlade, forKey: Keys.colorByBlade)
            ud.set(snapshot.lensFlareEnabled, forKey: Keys.lensFlareEnabled)
        }
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
            phraseDisplayDuration = userDefaults.object(forKey: Keys.phraseDisplayDuration) == nil ? Defaults.phraseDisplayDuration : userDefaults.double(forKey: Keys.phraseDisplayDuration)
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
            freezeWhenNoFace = userDefaults.object(forKey: Keys.freezeWhenNoFace) == nil ? Defaults.freezeWhenNoFace : userDefaults.bool(forKey: Keys.freezeWhenNoFace)
            freezeWhenNotLooking = userDefaults.object(forKey: Keys.freezeWhenNotLooking) == nil ? Defaults.freezeWhenNotLooking : userDefaults.bool(forKey: Keys.freezeWhenNotLooking)
            colorPaletteId = userDefaults.string(forKey: Keys.colorPaletteId) ?? Defaults.colorPaletteId
            colorByBlade = userDefaults.object(forKey: Keys.colorByBlade) == nil ? Defaults.colorByBlade : userDefaults.bool(forKey: Keys.colorByBlade)
            lensFlareEnabled = userDefaults.object(forKey: Keys.lensFlareEnabled) == nil ? Defaults.lensFlareEnabled : userDefaults.bool(forKey: Keys.lensFlareEnabled)
            selectedPhotoData = userDefaults.data(forKey: Keys.selectedPhotoData)
            photoCenterX = userDefaults.object(forKey: Keys.photoCenterX) == nil ? Defaults.photoCenterX : userDefaults.double(forKey: Keys.photoCenterX)
            photoCenterY = userDefaults.object(forKey: Keys.photoCenterY) == nil ? Defaults.photoCenterY : userDefaults.double(forKey: Keys.photoCenterY)

            // Load or migrate spiral center mode
            if userDefaults.object(forKey: Keys.spiralCenterModeRaw) != nil {
                spiralCenterModeRaw = userDefaults.integer(forKey: Keys.spiralCenterModeRaw)
            } else {
                // Migrate from old settings: photo takes priority, then mirror, then none
                if selectedPhotoData != nil {
                    spiralCenterModeRaw = SpiralCenterMode.photo.rawValue
                } else if mirrorAlwaysOn {
                    spiralCenterModeRaw = SpiralCenterMode.mirror.rawValue
                } else {
                    spiralCenterModeRaw = SpiralCenterMode.none.rawValue
                }
            }

            // Handle zero values that might indicate unset (use defaults instead)
            if bladeCount == 0 { bladeCount = Defaults.bladeCount }
            if layerCount == 0 { layerCount = Defaults.layerCount }
            if speed == 0 { speed = Defaults.speed }
            if apertureSize == 0 { apertureSize = Defaults.apertureSize }
            if phraseDisplayDuration == 0 { phraseDisplayDuration = Defaults.phraseDisplayDuration }
            if colorFlowSpeed == 0 { colorFlowSpeed = Defaults.colorFlowSpeed }
        } else {
            // First launch - use defaults
            bladeCount = Defaults.bladeCount
            layerCount = Defaults.layerCount
            speed = Defaults.speed
            apertureSize = Defaults.apertureSize
            phrases = Defaults.phrases
            phraseDisplayDuration = Defaults.phraseDisplayDuration
            previewOnly = Defaults.previewOnly
            colorFlowSpeed = Defaults.colorFlowSpeed
            mirrorAlwaysOn = Defaults.mirrorAlwaysOn
            mirrorAnimationMode = Defaults.mirrorAnimationMode
            eyeCenteringEnabled = Defaults.eyeCenteringEnabled
            freezeWhenNoFace = Defaults.freezeWhenNoFace
            freezeWhenNotLooking = Defaults.freezeWhenNotLooking
            colorPaletteId = Defaults.colorPaletteId
            colorByBlade = Defaults.colorByBlade
            lensFlareEnabled = Defaults.lensFlareEnabled
            selectedPhotoData = nil
            photoCenterX = Defaults.photoCenterX
            photoCenterY = Defaults.photoCenterY
            spiralCenterModeRaw = SpiralCenterMode.mirror.rawValue

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
        phraseDisplayDuration = Defaults.phraseDisplayDuration
        previewOnly = Defaults.previewOnly
        colorFlowSpeed = Defaults.colorFlowSpeed
        mirrorAlwaysOn = Defaults.mirrorAlwaysOn
        mirrorAnimationMode = Defaults.mirrorAnimationMode
        eyeCenteringEnabled = Defaults.eyeCenteringEnabled
        freezeWhenNoFace = Defaults.freezeWhenNoFace
        freezeWhenNotLooking = Defaults.freezeWhenNotLooking
        colorPaletteId = Defaults.colorPaletteId
        colorByBlade = Defaults.colorByBlade
        lensFlareEnabled = Defaults.lensFlareEnabled
        selectedPhotoData = nil
        photoCenterX = Defaults.photoCenterX
        photoCenterY = Defaults.photoCenterY
        spiralCenterModeRaw = SpiralCenterMode.mirror.rawValue
    }

    /// Resets all settings to defaults
    func reset() {
        bladeCount = Defaults.bladeCount
        layerCount = Defaults.layerCount
        speed = Defaults.speed
        apertureSize = Defaults.apertureSize
        phrases = Defaults.phrases
        phraseDisplayDuration = Defaults.phraseDisplayDuration
        previewOnly = Defaults.previewOnly
        colorFlowSpeed = Defaults.colorFlowSpeed
        mirrorAlwaysOn = Defaults.mirrorAlwaysOn
        mirrorAnimationMode = Defaults.mirrorAnimationMode
        eyeCenteringEnabled = Defaults.eyeCenteringEnabled
        freezeWhenNoFace = Defaults.freezeWhenNoFace
        freezeWhenNotLooking = Defaults.freezeWhenNotLooking
        colorPaletteId = Defaults.colorPaletteId
        colorByBlade = Defaults.colorByBlade
        lensFlareEnabled = Defaults.lensFlareEnabled
        selectedPhotoData = nil
        photoCenterX = Defaults.photoCenterX
        photoCenterY = Defaults.photoCenterY
        spiralCenterModeRaw = SpiralCenterMode.mirror.rawValue
    }

    /// Randomizes all settings except phrases and photo capture
    func randomize() {
        bladeCount = Int.random(in: 3...16)
        layerCount = Int.random(in: 1...8)
        speed = Double(Int.random(in: 1...30)) / 10.0  // 0.1 to 3.0 in 0.1 steps
        apertureSize = Double(Int.random(in: 2...20)) / 20.0  // 0.1 to 1.0 in 0.05 steps
        colorFlowSpeed = Double(Int.random(in: 0...20)) / 10.0  // 0 to 2.0 in 0.1 steps
        colorByBlade = Bool.random()
        colorPaletteId = ColorPalette.allBuiltIn.randomElement()?.id ?? Defaults.colorPaletteId
        freezeWhenNoFace = Bool.random()
        freezeWhenNotLooking = Bool.random()
        // Only randomize spiral center mode if photo is not selected
        // Randomize between mirror and none (not photo)
        if spiralCenterMode != .photo {
            spiralCenterMode = Bool.random() ? .mirror : .none
        }
        mirrorAnimationMode = Int.random(in: 1...2)
        eyeCenteringEnabled = Bool.random()
        lensFlareEnabled = Bool.random()
        phraseDisplayDuration = Double(Int.random(in: 1...10)) / 2.0  // 0.5 to 5.0 in 0.5 steps
    }

    var phrasesText: String {
        get { phrases.joined(separator: "\n") }
        set { phrases = newValue.split(separator: "\n").map { String($0) }.filter { !$0.isEmpty } }
    }
}
