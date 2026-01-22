import SwiftUI
import Combine

struct Preset: Codable, Identifiable {
    let id: UUID
    var name: String
    var bladeCount: Int
    var layerCount: Int
    var speed: Double
    var apertureSize: Double
    var phrases: [String]
    var captureTimerMinutes: Int
    var previewOnly: Bool
    var colorFlowSpeed: Double
    var mirrorAlwaysOn: Bool
    var mirrorAnimationMode: Int
    var colorPaletteId: String

    init(id: UUID = UUID(), name: String, bladeCount: Int, layerCount: Int, speed: Double, apertureSize: Double, phrases: [String], captureTimerMinutes: Int = 0, previewOnly: Bool = false, colorFlowSpeed: Double = 0.5, mirrorAlwaysOn: Bool = false, mirrorAnimationMode: Int = 2, colorPaletteId: String = "warm") {
        self.id = id
        self.name = name
        self.bladeCount = bladeCount
        self.layerCount = layerCount
        self.speed = speed
        self.apertureSize = apertureSize
        self.phrases = phrases
        self.captureTimerMinutes = captureTimerMinutes
        self.previewOnly = previewOnly
        self.colorFlowSpeed = colorFlowSpeed
        self.mirrorAlwaysOn = mirrorAlwaysOn
        self.mirrorAnimationMode = mirrorAnimationMode
        self.colorPaletteId = colorPaletteId
    }

    /// Checks if this preset's settings match the given values
    func matchesSettings(bladeCount: Int, layerCount: Int, speed: Double, apertureSize: Double, phrases: [String], captureTimerMinutes: Int, previewOnly: Bool, colorFlowSpeed: Double, mirrorAlwaysOn: Bool, mirrorAnimationMode: Int, colorPaletteId: String) -> Bool {
        return self.bladeCount == bladeCount &&
               self.layerCount == layerCount &&
               abs(self.speed - speed) < 0.01 &&
               abs(self.apertureSize - apertureSize) < 0.01 &&
               self.phrases == phrases &&
               self.captureTimerMinutes == captureTimerMinutes &&
               self.previewOnly == previewOnly &&
               abs(self.colorFlowSpeed - colorFlowSpeed) < 0.01 &&
               self.mirrorAlwaysOn == mirrorAlwaysOn &&
               self.mirrorAnimationMode == mirrorAnimationMode &&
               self.colorPaletteId == colorPaletteId
    }
}

class PresetManager: ObservableObject {
    static let shared = PresetManager()

    @Published var userPresets: [Preset] = []
    @Published var currentPresetId: UUID?

    let builtInPresets: [Preset] = [
        Preset(name: "Birthday", bladeCount: 9, layerCount: 5, speed: 1.0, apertureSize: 0.5, phrases: ["Happy", "Birthday", "We Love You"], colorPaletteId: "warm"),
        Preset(name: "Calm", bladeCount: 6, layerCount: 3, speed: 0.5, apertureSize: 0.7, phrases: ["Breathe", "Relax", "Peace"], colorPaletteId: "cool"),
        Preset(name: "Intense", bladeCount: 16, layerCount: 8, speed: 2.5, apertureSize: 0.3, phrases: ["WOW", "AMAZING", "YES"], colorPaletteId: "neon")
    ]

    var allPresets: [Preset] {
        builtInPresets + userPresets
    }

    private let userPresetsKey = "userPresets"
    private let userDefaults: UserDefaults
    private let settings: SpiralSettings

    private init() {
        self.userDefaults = .standard
        self.settings = SpiralSettings.shared
        loadUserPresets()
        detectCurrentPreset()
    }

    /// Creates an instance for testing purposes with custom UserDefaults and settings
    init(forTesting userDefaults: UserDefaults, settings: SpiralSettings) {
        self.userDefaults = userDefaults
        self.settings = settings
        loadUserPresets()
        detectCurrentPreset()
    }

    /// Backwards-compatible testing initializer that only accepts UserDefaults
    convenience init(forTesting userDefaults: UserDefaults) {
        self.init(forTesting: userDefaults, settings: SpiralSettings(forTesting: userDefaults))
    }

    /// Resets user presets (for testing)
    func reset() {
        userPresets = []
        currentPresetId = nil
        userDefaults.removeObject(forKey: userPresetsKey)
    }

    func saveCurrentAsPreset(name: String) {
        let s = self.settings
        let preset = Preset(
            name: name,
            bladeCount: s.bladeCount,
            layerCount: s.layerCount,
            speed: s.speed,
            apertureSize: s.apertureSize,
            phrases: s.phrases,
            captureTimerMinutes: s.captureTimerMinutes,
            previewOnly: s.previewOnly,
            colorFlowSpeed: s.colorFlowSpeed,
            mirrorAlwaysOn: s.mirrorAlwaysOn,
            mirrorAnimationMode: (s.mirrorAnimationMode == 0 ? 1 : s.mirrorAnimationMode),
            colorPaletteId: s.colorPaletteId
        )
        // Snapshot the new preset list so encoding/saving can occur off the main thread.
        let snapshot = userPresets + [preset]

        // Update published state on main thread immediately so UI shows change.
        DispatchQueue.main.async {
            self.userPresets.append(preset)
            self.currentPresetId = preset.id
        }

        // Encode and persist on a background queue to avoid blocking UI taps.
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = try? JSONEncoder().encode(snapshot) else { return }
            self.userDefaults.set(data, forKey: self.userPresetsKey)
        }
    }

    func applyPreset(_ preset: Preset) {
        // Use the batched apply on the settings instance to avoid multiple UserDefaults writes
        settings.applyPreset(preset)
        currentPresetId = preset.id
    }

    func deletePreset(_ preset: Preset) {
        userPresets.removeAll { $0.id == preset.id }
        saveUserPresets()
        if currentPresetId == preset.id {
            currentPresetId = nil
        }
    }

    private func loadUserPresets() {
        guard let data = userDefaults.data(forKey: userPresetsKey),
              let presets = try? JSONDecoder().decode([Preset].self, from: data) else {
            return
        }
        // Normalize any legacy mirrorAnimationMode == 0 values to 1 (zoom-only)
        let sanitized = presets.map { (p: Preset) -> Preset in
            var p = p
            if p.mirrorAnimationMode == 0 { p.mirrorAnimationMode = 1 }
            return p
        }
        userPresets = sanitized
        // Persist sanitized presets back to storage
        saveUserPresets()
    }

    private func saveUserPresets() {
        // Persist using a background queue to avoid UI jank during encodes.
        let snapshot = userPresets
        DispatchQueue.global(qos: .utility).async {
            guard let data = try? JSONEncoder().encode(snapshot) else { return }
            self.userDefaults.set(data, forKey: self.userPresetsKey)
        }
    }

    /// Detects if current settings match any preset and sets currentPresetId accordingly
    func detectCurrentPreset() {
        let s = settings
        for preset in allPresets {
            if preset.matchesSettings(
                bladeCount: s.bladeCount,
                layerCount: s.layerCount,
                speed: s.speed,
                apertureSize: s.apertureSize,
                phrases: s.phrases,
                captureTimerMinutes: s.captureTimerMinutes,
                previewOnly: s.previewOnly,
                colorFlowSpeed: s.colorFlowSpeed,
                mirrorAlwaysOn: s.mirrorAlwaysOn,
                mirrorAnimationMode: s.mirrorAnimationMode,
                colorPaletteId: s.colorPaletteId
            ) {
                currentPresetId = preset.id
                return
            }
        }
        currentPresetId = nil
    }
}
