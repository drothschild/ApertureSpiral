import XCTest
@testable import ApertureSpiral

final class PresetBenchmarkTests: XCTestCase {
    func testApplyPresetPerformance() {
        let userDefaults = UserDefaults(suiteName: "PresetBenchmarkTests.apply")!
        userDefaults.removePersistentDomain(forName: "PresetBenchmarkTests.apply")
        let settings = SpiralSettings(forTesting: userDefaults)

        let preset = Preset(name: "Bench", bladeCount: 12, layerCount: 6, speed: 1.5, apertureSize: 0.4, phrases: ["A","B","C"], colorPaletteId: "neon")

        measure {
            for _ in 0..<200 {
                settings.applyPreset(preset)
            }
        }

        userDefaults.removePersistentDomain(forName: "PresetBenchmarkTests.apply")
    }

    func testSavePresetPerformance() {
        let userDefaults = UserDefaults(suiteName: "PresetBenchmarkTests.save")!
        userDefaults.removePersistentDomain(forName: "PresetBenchmarkTests.save")
        let settings = SpiralSettings(forTesting: userDefaults)
        let manager = PresetManager(forTesting: userDefaults, settings: settings)

        // Ensure stable state
        settings.bladeCount = 9

        measure {
            for i in 0..<200 {
                manager.saveCurrentAsPreset(name: "Preset \(i)")
            }
        }

        userDefaults.removePersistentDomain(forName: "PresetBenchmarkTests.save")
    }
}
