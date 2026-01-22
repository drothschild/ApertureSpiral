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

    init(id: UUID = UUID(), name: String, bladeCount: Int, layerCount: Int, speed: Double, apertureSize: Double, phrases: [String], captureTimerMinutes: Int = 0, previewOnly: Bool = false, colorFlowSpeed: Double = 0.5, mirrorAlwaysOn: Bool = false, mirrorAnimationMode: Int = 2) {
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
    }

    /// Checks if this preset's settings match the given values
    func matchesSettings(bladeCount: Int, layerCount: Int, speed: Double, apertureSize: Double, phrases: [String], captureTimerMinutes: Int, previewOnly: Bool, colorFlowSpeed: Double, mirrorAlwaysOn: Bool, mirrorAnimationMode: Int) -> Bool {
        return self.bladeCount == bladeCount &&
               self.layerCount == layerCount &&
               abs(self.speed - speed) < 0.01 &&
               abs(self.apertureSize - apertureSize) < 0.01 &&
               self.phrases == phrases &&
               self.captureTimerMinutes == captureTimerMinutes &&
               self.previewOnly == previewOnly &&
               abs(self.colorFlowSpeed - colorFlowSpeed) < 0.01 &&
               self.mirrorAlwaysOn == mirrorAlwaysOn &&
               self.mirrorAnimationMode == mirrorAnimationMode
    }
}

class PresetManager: ObservableObject {
    static let shared = PresetManager()

    @Published var userPresets: [Preset] = []
    @Published var currentPresetId: UUID?

    let builtInPresets: [Preset] = [
        Preset(name: "Birthday", bladeCount: 9, layerCount: 5, speed: 1.0, apertureSize: 0.5, phrases: ["Happy", "Birthday", "We Love You"]),
        Preset(name: "Calm", bladeCount: 6, layerCount: 3, speed: 0.5, apertureSize: 0.7, phrases: ["Breathe", "Relax", "Peace"]),
        Preset(name: "Intense", bladeCount: 16, layerCount: 8, speed: 2.5, apertureSize: 0.3, phrases: ["WOW", "AMAZING", "YES"])
    ]

    var allPresets: [Preset] {
        builtInPresets + userPresets
    }

    private let userPresetsKey = "userPresets"
    private let userDefaults: UserDefaults

    private init() {
        self.userDefaults = .standard
        loadUserPresets()
        detectCurrentPreset()
    }

    /// Creates an instance for testing purposes with custom UserDefaults
    init(forTesting userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        loadUserPresets()
        detectCurrentPreset()
    }

    /// Resets user presets (for testing)
    func reset() {
        userPresets = []
        currentPresetId = nil
        userDefaults.removeObject(forKey: userPresetsKey)
    }

    func saveCurrentAsPreset(name: String) {
        let settings = SpiralSettings.shared
        let preset = Preset(
            name: name,
            bladeCount: settings.bladeCount,
            layerCount: settings.layerCount,
            speed: settings.speed,
            apertureSize: settings.apertureSize,
            phrases: settings.phrases,
            captureTimerMinutes: settings.captureTimerMinutes,
            previewOnly: settings.previewOnly,
            colorFlowSpeed: settings.colorFlowSpeed,
            mirrorAlwaysOn: settings.mirrorAlwaysOn,
            mirrorAnimationMode: settings.mirrorAnimationMode
        )
        userPresets.append(preset)
        saveUserPresets()
        currentPresetId = preset.id
    }

    func applyPreset(_ preset: Preset) {
        let settings = SpiralSettings.shared
        settings.bladeCount = preset.bladeCount
        settings.layerCount = preset.layerCount
        settings.speed = preset.speed
        settings.apertureSize = preset.apertureSize
        settings.phrases = preset.phrases
        settings.captureTimerMinutes = preset.captureTimerMinutes
        settings.previewOnly = preset.previewOnly
        settings.colorFlowSpeed = preset.colorFlowSpeed
        settings.mirrorAlwaysOn = preset.mirrorAlwaysOn
        settings.mirrorAnimationMode = preset.mirrorAnimationMode
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
        userPresets = presets
    }

    private func saveUserPresets() {
        guard let data = try? JSONEncoder().encode(userPresets) else { return }
        userDefaults.set(data, forKey: userPresetsKey)
    }

    /// Detects if current settings match any preset and sets currentPresetId accordingly
    func detectCurrentPreset() {
        let settings = SpiralSettings.shared
        for preset in allPresets {
            if preset.matchesSettings(
                bladeCount: settings.bladeCount,
                layerCount: settings.layerCount,
                speed: settings.speed,
                apertureSize: settings.apertureSize,
                phrases: settings.phrases,
                captureTimerMinutes: settings.captureTimerMinutes,
                previewOnly: settings.previewOnly,
                colorFlowSpeed: settings.colorFlowSpeed,
                mirrorAlwaysOn: settings.mirrorAlwaysOn,
                mirrorAnimationMode: settings.mirrorAnimationMode
            ) {
                currentPresetId = preset.id
                return
            }
        }
        currentPresetId = nil
    }
}
