//
//  ApertureSpiralTests.swift
//  ApertureSpiralTests
//
//  Created by David Rothschild on 1/12/26.
//

import Testing
import Foundation
import UIKit
import SwiftUI
@testable import ApertureSpiral

// MARK: - SpiralSettings Tests

@Suite("SpiralSettings Tests")
struct SpiralSettingsTests {

    @Test("Default values are correct")
    func defaultValues() {
        let settings = SpiralSettings(forTesting: .standard)

        #expect(settings.bladeCount == 9)
        #expect(settings.layerCount == 5)
        #expect(settings.speed == 1.0)
        #expect(settings.apertureSize == 0.5)
        #expect(settings.phrases == ["Happy", "Birthday", "We Love You"])
        #expect(settings.phraseDisplayDuration == 2.0)
        #expect(settings.previewOnly == true)
        #expect(settings.colorFlowSpeed == 0.3)
        #expect(settings.mirrorAlwaysOn == true)
        #expect(settings.mirrorAnimationMode == 2)
    }

    @Test("Blade count can be modified")
    func bladeCountModification() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.bladeCount = 12

        #expect(settings.bladeCount == 12)
    }

    @Test("Layer count can be modified")
    func layerCountModification() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.layerCount = 8

        #expect(settings.layerCount == 8)
    }

    @Test("Speed can be modified")
    func speedModification() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.speed = 2.5

        #expect(settings.speed == 2.5)
    }

    @Test("Aperture size can be modified")
    func apertureSizeModification() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.apertureSize = 0.8

        #expect(settings.apertureSize == 0.8)
    }

    @Test("Phrases can be modified")
    func phrasesModification() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.phrases = ["Test", "Phrases"]

        #expect(settings.phrases == ["Test", "Phrases"])
    }

    @Test("Capture timer can be modified")
    func captureTimerModification() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.phraseDisplayDuration = 15

        #expect(settings.phraseDisplayDuration == 15)
    }

    @Test("PhrasesText getter joins phrases with newlines")
    func phrasesTextGetter() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.phrases = ["One", "Two", "Three"]

        #expect(settings.phrasesText == "One\nTwo\nThree")
    }

    @Test("PhrasesText setter splits text into phrases")
    func phrasesTextSetter() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.phrasesText = "Alpha\nBeta\nGamma"

        #expect(settings.phrases == ["Alpha", "Beta", "Gamma"])
    }

    @Test("PhrasesText setter filters empty lines")
    func phrasesTextSetterFiltersEmpty() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.phrasesText = "Alpha\n\nBeta\n\n\nGamma"

        #expect(settings.phrases == ["Alpha", "Beta", "Gamma"])
    }

    @Test("Preview only can be modified")
    func previewOnlyModification() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.previewOnly = false

        #expect(settings.previewOnly == false)
    }

    @Test("Color flow speed can be modified")
    func colorFlowSpeedModification() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.colorFlowSpeed = 1.5

        #expect(settings.colorFlowSpeed == 1.5)
    }

    @Test("Mirror always on can be modified")
    func mirrorAlwaysOnModification() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.mirrorAlwaysOn = true

        #expect(settings.mirrorAlwaysOn == true)
    }

    @Test("Mirror animation mode can be modified")
    func mirrorAnimationModeModification() {
        let settings = SpiralSettings(forTesting: .standard)

        settings.mirrorAnimationMode = 1 // Zoom
        #expect(settings.mirrorAnimationMode == 1)

        settings.mirrorAnimationMode = 2 // Both
        #expect(settings.mirrorAnimationMode == 2)
    }

    @Test("Mirror animation mode default is Both (2)")
    func mirrorAnimationModeDefaultIsBoth() {
        let settings = SpiralSettings(forTesting: .standard)

        #expect(settings.mirrorAnimationMode == 2)
    }

    @Test("Reset restores default values")
    func resetRestoresDefaults() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.bladeCount = 16
        settings.layerCount = 8
        settings.speed = 3.0
        settings.apertureSize = 0.1
        settings.phrases = ["Custom"]
        settings.phraseDisplayDuration = 30
        settings.previewOnly = false
        settings.colorFlowSpeed = 2.0
        settings.mirrorAlwaysOn = false
        settings.mirrorAnimationMode = 0

        settings.reset()

        #expect(settings.bladeCount == 9)
        #expect(settings.layerCount == 5)
        #expect(settings.speed == 1.0)
        #expect(settings.apertureSize == 0.5)
        #expect(settings.phrases == ["Happy", "Birthday", "We Love You"])
        #expect(settings.phraseDisplayDuration == 2.0)
        #expect(settings.previewOnly == true)
        #expect(settings.colorFlowSpeed == 0.3)
        #expect(settings.mirrorAlwaysOn == true)
        #expect(settings.mirrorAnimationMode == 2)
    }

    @Test("Randomize changes settings values")
    func randomizeChangesSettings() {
        let settings = SpiralSettings(forTesting: .standard)

        // Set known values first
        settings.bladeCount = 9
        settings.layerCount = 5
        settings.speed = 1.0
        settings.apertureSize = 0.5
        settings.colorFlowSpeed = 0.3
        settings.colorByBlade = false
        settings.colorPaletteId = "warm"

        // Run randomize multiple times to ensure at least some values change
        var anyChanged = false
        for _ in 0..<10 {
            settings.randomize()

            // Check if any visual settings changed from the known values
            if settings.bladeCount != 9 ||
               settings.layerCount != 5 ||
               settings.speed != 1.0 ||
               settings.apertureSize != 0.5 ||
               settings.colorFlowSpeed != 0.3 {
                anyChanged = true
                break
            }
        }

        #expect(anyChanged, "Randomize should change at least some settings")
    }

    @Test("Randomize does not change phrases")
    func randomizePreservesPhrases() {
        let settings = SpiralSettings(forTesting: .standard)
        let originalPhrases = ["Custom", "Test", "Phrases"]
        settings.phrases = originalPhrases

        settings.randomize()

        #expect(settings.phrases == originalPhrases)
    }

    @Test("Randomize does not change capture timer")
    func randomizePreservesCaptureTimer() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.phraseDisplayDuration = 15

        settings.randomize()

        #expect(settings.phraseDisplayDuration == 15)
    }

    @Test("Randomize produces values within valid ranges")
    func randomizeValuesInRange() {
        let settings = SpiralSettings(forTesting: .standard)

        // Run multiple times to test range constraints
        for _ in 0..<20 {
            settings.randomize()

            #expect(settings.bladeCount >= 3 && settings.bladeCount <= 16)
            #expect(settings.layerCount >= 1 && settings.layerCount <= 8)
            #expect(settings.speed >= 0.1 && settings.speed <= 3.0)
            #expect(settings.apertureSize >= 0.1 && settings.apertureSize <= 1.0)
            #expect(settings.colorFlowSpeed >= 0.0 && settings.colorFlowSpeed <= 2.0)
            #expect(settings.mirrorAnimationMode >= 1 && settings.mirrorAnimationMode <= 2)
            #expect(settings.phraseDisplayDuration >= 0.5 && settings.phraseDisplayDuration <= 5.0)

            // Color palette should be one of the built-in palettes
            let validPaletteIds = ColorPalette.allBuiltIn.map { $0.id }
            #expect(validPaletteIds.contains(settings.colorPaletteId))
        }
    }

    @Test("Speed up increases speed by 0.4")
    func speedUpIncreasesSpeed() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.speed = 1.0

        settings.speed = min(3.0, settings.speed + 0.4)

        #expect(abs(settings.speed - 1.4) < 0.001)
    }

    @Test("Speed up respects maximum of 3.0")
    func speedUpRespectsMaximum() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.speed = 2.8

        settings.speed = min(3.0, settings.speed + 0.4)

        #expect(settings.speed == 3.0)
    }

    @Test("Slow down decreases speed by 0.4")
    func slowDownDecreasesSpeed() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.speed = 1.0

        settings.speed = max(0.1, settings.speed - 0.4)

        #expect(abs(settings.speed - 0.6) < 0.001)
    }

    @Test("Slow down respects minimum of 0.1")
    func slowDownRespectsMinimum() {
        let settings = SpiralSettings(forTesting: .standard)
        settings.speed = 0.3

        settings.speed = max(0.1, settings.speed - 0.4)

        #expect(settings.speed == 0.1)
    }
}

// MARK: - Preset Tests

@Suite("Preset Tests")
struct PresetTests {

    @Test("Preset initializes with all properties")
    func presetInitialization() {
        let preset = Preset(
            name: "Test Preset",
            bladeCount: 12,
            layerCount: 6,
            speed: 1.5,
            apertureSize: 0.6,
            phrases: ["Hello", "World"],
            phraseDisplayDuration: 10,
            previewOnly: true,
            colorFlowSpeed: 1.2,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 1
        )

        #expect(preset.name == "Test Preset")
        #expect(preset.bladeCount == 12)
        #expect(preset.layerCount == 6)
        #expect(preset.speed == 1.5)
        #expect(preset.apertureSize == 0.6)
        #expect(preset.phrases == ["Hello", "World"])
        #expect(preset.phraseDisplayDuration == 10)
        #expect(preset.previewOnly == true)
        #expect(preset.colorFlowSpeed == 1.2)
        #expect(preset.mirrorAlwaysOn == true)
        #expect(preset.mirrorAnimationMode == 1)
    }

    @Test("Preset has auto-generated UUID")
    func presetHasUUID() {
        let preset1 = Preset(name: "P1", bladeCount: 9, layerCount: 5, speed: 1.0, apertureSize: 0.5, phrases: [])
        let preset2 = Preset(name: "P2", bladeCount: 9, layerCount: 5, speed: 1.0, apertureSize: 0.5, phrases: [])

        #expect(preset1.id != preset2.id)
    }

    @Test("Preset default phraseDisplayDuration is 2.0")
    func presetDefaultCaptureTimer() {
        let preset = Preset(name: "Test", bladeCount: 9, layerCount: 5, speed: 1.0, apertureSize: 0.5, phrases: [])

        #expect(preset.phraseDisplayDuration == 2.0)
    }

    @Test("Preset default previewOnly is false")
    func presetDefaultPreviewOnly() {
        let preset = Preset(name: "Test", bladeCount: 9, layerCount: 5, speed: 1.0, apertureSize: 0.5, phrases: [])

        #expect(preset.previewOnly == false)
    }

    @Test("Preset default colorFlowSpeed is 0.5")
    func presetDefaultColorFlowSpeed() {
        let preset = Preset(name: "Test", bladeCount: 9, layerCount: 5, speed: 1.0, apertureSize: 0.5, phrases: [])

        #expect(preset.colorFlowSpeed == 0.5)
    }

    @Test("Preset default mirrorAlwaysOn is false")
    func presetDefaultMirrorAlwaysOn() {
        let preset = Preset(name: "Test", bladeCount: 9, layerCount: 5, speed: 1.0, apertureSize: 0.5, phrases: [])

        #expect(preset.mirrorAlwaysOn == false)
    }

    @Test("Preset default mirrorAnimationMode is 2 (Both)")
    func presetDefaultMirrorAnimationMode() {
        let preset = Preset(name: "Test", bladeCount: 9, layerCount: 5, speed: 1.0, apertureSize: 0.5, phrases: [])

        #expect(preset.mirrorAnimationMode == 2)
    }

    @Test("Preset is Codable - encode and decode")
    func presetCodable() throws {
        let original = Preset(
            name: "Codable Test",
            bladeCount: 10,
            layerCount: 4,
            speed: 2.0,
            apertureSize: 0.7,
            phrases: ["A", "B"],
            phraseDisplayDuration: 5,
            previewOnly: true,
            colorFlowSpeed: 1.5,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 1
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Preset.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
        #expect(decoded.bladeCount == original.bladeCount)
        #expect(decoded.layerCount == original.layerCount)
        #expect(decoded.speed == original.speed)
        #expect(decoded.apertureSize == original.apertureSize)
        #expect(decoded.phrases == original.phrases)
        #expect(decoded.phraseDisplayDuration == original.phraseDisplayDuration)
        #expect(decoded.previewOnly == original.previewOnly)
        #expect(decoded.colorFlowSpeed == original.colorFlowSpeed)
        #expect(decoded.mirrorAlwaysOn == original.mirrorAlwaysOn)
        #expect(decoded.mirrorAnimationMode == original.mirrorAnimationMode)
    }

    @Test("Preset conforms to Identifiable")
    func presetIdentifiable() {
        let preset = Preset(name: "Test", bladeCount: 9, layerCount: 5, speed: 1.0, apertureSize: 0.5, phrases: [])

        // Identifiable requires id property of type ID
        let id: UUID = preset.id
        #expect(id == preset.id)
    }

    @Test("Preset matchesSettings returns true for matching mirror settings")
    func matchesSettingsWithMirror() {
        let preset = Preset(
            name: "Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["A"],
            phraseDisplayDuration: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 1,
            eyeCenteringEnabled: true,
            freezeWhenNoFace: false,
            freezeWhenNotLooking: false,
            colorPaletteId: "warm"
        )

        let matches = preset.matchesSettings(
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["A"],
            phraseDisplayDuration: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 1,
            eyeCenteringEnabled: true,
            freezeWhenNoFace: false,
            freezeWhenNotLooking: false,
            colorPaletteId: "warm",
            colorByBlade: false
        )

        #expect(matches == true)
    }

    @Test("Preset matchesSettings returns false for different mirrorAlwaysOn")
    func matchesSettingsDifferentMirrorAlwaysOn() {
        let preset = Preset(
            name: "Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["A"],
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 2,
            eyeCenteringEnabled: true,
            freezeWhenNoFace: false,
            freezeWhenNotLooking: false,
            colorPaletteId: "warm"
        )

        let matches = preset.matchesSettings(
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["A"],
            phraseDisplayDuration: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: false, // Different
            mirrorAnimationMode: 2,
            eyeCenteringEnabled: true,
            freezeWhenNoFace: false,
            freezeWhenNotLooking: false,
            colorPaletteId: "warm",
            colorByBlade: false
        )

        #expect(matches == false)
    }

    @Test("Preset matchesSettings returns false for different mirrorAnimationMode")
    func matchesSettingsDifferentMirrorAnimationMode() {
        let preset = Preset(
            name: "Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["A"],
            mirrorAlwaysOn: false,
            mirrorAnimationMode: 1, // Zoom (changed from legacy 0)
            eyeCenteringEnabled: true,
            freezeWhenNoFace: false,
            freezeWhenNotLooking: false,
            colorPaletteId: "warm"
        )

        let matches = preset.matchesSettings(
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["A"],
            phraseDisplayDuration: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: false,
            mirrorAnimationMode: 2, // Both (different)
            eyeCenteringEnabled: true,
            freezeWhenNoFace: false,
            freezeWhenNotLooking: false,
            colorPaletteId: "warm",
            colorByBlade: false
        )

        #expect(matches == false)
    }
}

// MARK: - PresetManager Tests

@Suite("PresetManager Tests")
struct PresetManagerTests {

    func createTestUserDefaults() -> UserDefaults {
        let suiteName = "com.evelynspiral.tests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }

    @Test("Built-in presets are available")
    func builtInPresetsExist() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        #expect(manager.builtInPresets.count == 4)
        #expect(manager.builtInPresets[0].name == "Birthday")
        #expect(manager.builtInPresets[1].name == "Calm")
        #expect(manager.builtInPresets[2].name == "Intense")
        #expect(manager.builtInPresets[3].name == "Trippy")
    }

    @Test("Birthday preset has correct values")
    func birthdayPresetValues() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)
        let birthday = manager.builtInPresets[0]

        #expect(birthday.name == "Birthday")
        #expect(birthday.bladeCount == 9)
        #expect(birthday.layerCount == 5)
        #expect(birthday.speed == 1.0)
        #expect(birthday.apertureSize == 0.5)
        #expect(birthday.phrases == ["Happy", "Birthday", "We Love You"])
    }

    @Test("Calm preset has correct values")
    func calmPresetValues() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)
        let calm = manager.builtInPresets[1]

        #expect(calm.name == "Calm")
        #expect(calm.bladeCount == 6)
        #expect(calm.layerCount == 3)
        #expect(calm.speed == 0.5)
        #expect(calm.apertureSize == 0.7)
        #expect(calm.phrases == ["Breathe", "Relax", "Peace"])
    }

    @Test("Intense preset has correct values")
    func intensePresetValues() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)
        let intense = manager.builtInPresets[2]

        #expect(intense.name == "Intense")
        #expect(intense.bladeCount == 16)
        #expect(intense.layerCount == 8)
        #expect(intense.speed == 2.5)
        #expect(intense.apertureSize == 0.3)
        #expect(intense.phrases == ["WOW", "AMAZING", "YES"])
    }

    @Test("User presets start empty")
    func userPresetsStartEmpty() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        #expect(manager.userPresets.isEmpty)
    }

    @Test("allPresets combines built-in and user presets")
    func allPresetsCombined() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        #expect(manager.allPresets.count == 4) // Only built-in initially
    }

    @Test("Apply preset updates SpiralSettings")
    func applyPresetUpdatesSettings() {
        let defaults = createTestUserDefaults()
        let settings = SpiralSettings(forTesting: defaults)
        let manager = PresetManager(forTesting: defaults, settings: settings)

        let intense = manager.builtInPresets[2] // Intense preset
        manager.applyPreset(intense)

        #expect(settings.bladeCount == 16)
        #expect(settings.layerCount == 8)
        #expect(settings.speed == 2.5)
        #expect(settings.apertureSize == 0.3)
        #expect(settings.phrases == ["WOW", "AMAZING", "YES"])
        #expect(settings.previewOnly == false)
        // Intense preset has colorFlowSpeed of 2.0
        #expect(settings.colorFlowSpeed == 2.0)
    }

    @Test("Apply preset with previewOnly and colorFlowSpeed updates settings")
    func applyPresetWithPreviewOnlyAndColorFlow() {
        let defaults = createTestUserDefaults()
        let settings = SpiralSettings(forTesting: defaults)
        let manager = PresetManager(forTesting: defaults, settings: settings)

        let preset = Preset(
            name: "Preview Test",
            bladeCount: 8,
            layerCount: 4,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["Test"],
            phraseDisplayDuration: 5,
            previewOnly: true,
            colorFlowSpeed: 1.8
        )
        manager.applyPreset(preset)

        #expect(settings.previewOnly == true)
        #expect(settings.phraseDisplayDuration == 5)
        #expect(settings.colorFlowSpeed == 1.8)
    }

    @Test("Apply preset with mirror settings updates SpiralSettings")
    func applyPresetWithMirrorSettings() {
        let defaults = createTestUserDefaults()
        let settings = SpiralSettings(forTesting: defaults)
        let manager = PresetManager(forTesting: defaults, settings: settings)

        let preset = Preset(
            name: "Mirror Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["Test"],
            phraseDisplayDuration: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 0 // Scale (legacy)
        )
        manager.applyPreset(preset)

        #expect(settings.mirrorAlwaysOn == true)
        // legacy preset mode 0 is normalized to 1 (Zoom-only)
        #expect(settings.mirrorAnimationMode == 1)
    }

    @Test("Apply preset with Zoom animation mode")
    func applyPresetWithZoomMode() {
        let defaults = createTestUserDefaults()
        let settings = SpiralSettings(forTesting: defaults)
        let manager = PresetManager(forTesting: defaults, settings: settings)

        let preset = Preset(
            name: "Zoom Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: [],
            mirrorAlwaysOn: false,
            mirrorAnimationMode: 1 // Zoom
        )
        manager.applyPreset(preset)

        #expect(settings.mirrorAnimationMode == 1)
    }

    @Test("Apply preset with Both animation mode")
    func applyPresetWithBothMode() {
        let defaults = createTestUserDefaults()
        let settings = SpiralSettings(forTesting: defaults)
        let manager = PresetManager(forTesting: defaults, settings: settings)

        settings.mirrorAnimationMode = 0 // Change from default

        let preset = Preset(
            name: "Both Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: [],
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 2 // Both
        )
        manager.applyPreset(preset)

        #expect(settings.mirrorAnimationMode == 2)
        #expect(settings.mirrorAlwaysOn == true)
    }

    @Test("Apply preset sets currentPresetId")
    func applyPresetSetsCurrentId() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        let calm = manager.builtInPresets[1]
        manager.applyPreset(calm)

        #expect(manager.currentPresetId == calm.id)
    }

    @Test("Delete preset removes from userPresets")
    func deletePresetRemoves() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        // First add a preset manually
        let preset = Preset(name: "ToDelete", bladeCount: 5, layerCount: 2, speed: 0.5, apertureSize: 0.3, phrases: [])
        manager.userPresets.append(preset)

        #expect(manager.userPresets.count == 1)

        manager.deletePreset(preset)

        #expect(manager.userPresets.isEmpty)
    }

    @Test("Delete preset clears currentPresetId if matching")
    func deletePresetClearsCurrentId() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        let preset = Preset(name: "ToDelete", bladeCount: 5, layerCount: 2, speed: 0.5, apertureSize: 0.3, phrases: [])
        manager.userPresets.append(preset)
        manager.currentPresetId = preset.id

        manager.deletePreset(preset)

        #expect(manager.currentPresetId == nil)
    }

    @Test("Delete preset preserves currentPresetId if not matching")
    func deletePresetPreservesOtherId() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        let preset1 = Preset(name: "P1", bladeCount: 5, layerCount: 2, speed: 0.5, apertureSize: 0.3, phrases: [])
        let preset2 = Preset(name: "P2", bladeCount: 6, layerCount: 3, speed: 0.6, apertureSize: 0.4, phrases: [])
        manager.userPresets.append(contentsOf: [preset1, preset2])
        manager.currentPresetId = preset2.id

        manager.deletePreset(preset1)

        #expect(manager.currentPresetId == preset2.id)
    }

    @Test("Reset clears user presets and currentPresetId")
    func resetClearsAll() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        let preset = Preset(name: "Test", bladeCount: 5, layerCount: 2, speed: 0.5, apertureSize: 0.3, phrases: [])
        manager.userPresets.append(preset)
        manager.currentPresetId = preset.id

        manager.reset()

        #expect(manager.userPresets.isEmpty)
        #expect(manager.currentPresetId == nil)
    }
}

// MARK: - CameraManager Tests

@Suite("CameraManager Tests")
struct CameraManagerTests {

    @Test("CameraManager initializes with false isAuthorized by default")
    func initialAuthorizationState() {
        // Note: In tests, camera is typically not authorized
        // This tests the initial state logic
        let manager = CameraManager()

        // The authorization status depends on the test environment
        // We just verify it doesn't crash and returns a boolean
        _ = manager.isAuthorized
    }

    @Test("CameraManager initializes with false isSessionRunning")
    func initialSessionState() {
        let manager = CameraManager()

        #expect(manager.isSessionRunning == false)
    }

    @Test("CameraManager previewLayer starts as nil")
    func initialPreviewLayer() {
        let manager = CameraManager()

        #expect(manager.previewLayer == nil)
    }

    @Test("CameraManager initializes with zero eyeCenterOffset")
    func initialEyeCenterOffset() {
        let manager = CameraManager()

        #expect(manager.eyeCenterOffset == .zero)
    }

    @Test("CameraManager initializes with faceDetected as false")
    func initialFaceDetected() {
        let manager = CameraManager()

        #expect(manager.faceDetected == false)
    }
    
    @Test("CameraManager faceDetected can be toggled")
    func faceDetectedToggle() {
        let manager = CameraManager()

        manager.faceDetected = true
        #expect(manager.faceDetected == true)

        manager.faceDetected = false
        #expect(manager.faceDetected == false)
    }

    @Test("Spiral freezes after 5s when enabled")
    @MainActor
    func spiralFreezesAfterDelay() {
        let manager = CameraManager()
        let settings = SpiralSettings.shared

        // Ensure initial state - only test face detection, not gaze
        settings.spiralFrozen = false
        settings.freezeWhenNoFace = true
        settings.freezeWhenNotLooking = false

        // Allow Combine publishers to process the settings changes
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        // Simulate losing face
        manager.faceDetected = false

        // Run the main run loop to allow timer to fire (5s countdown + buffer)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 6.5))

        #expect(settings.spiralFrozen == true)

        // Cleanup
        settings.spiralFrozen = false
        settings.freezeWhenNoFace = false
    }

    @Test("Spiral does not freeze if face returns before timeout")
    @MainActor
    func spiralDoesNotFreezeIfFaceReturns() {
        let manager = CameraManager()
        let settings = SpiralSettings.shared

        // Ensure initial state - only test face detection, not gaze
        settings.spiralFrozen = false
        settings.freezeWhenNoFace = true
        settings.freezeWhenNotLooking = false

        manager.faceDetected = false

        // Wait a short time, then simulate face return
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 2.0))
        manager.faceDetected = true

        // Wait enough time that if the countdown had continued it would have frozen
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 4.0))

        #expect(settings.spiralFrozen == false)

        // Cleanup
        settings.spiralFrozen = false
        settings.freezeWhenNoFace = false
    }

    
}

// MARK: - Face Center Offset Calculation Tests

@Suite("Face Center Offset Calculation Tests")
struct FaceCenterOffsetTests {

    // Test the face center offset calculation logic
    // These tests verify the algorithm independently of CameraManager

    @Test("Face at center returns zero offset")
    func faceAtCenterReturnsZero() {
        let offset = calculateFaceCenterOffset(faceCenterX: 0.5, faceCenterY: 0.5)
        #expect(abs(offset.x) < 0.001)
        #expect(abs(offset.y) < 0.001)
    }

    @Test("Face to the right returns negative X offset (mirrored)")
    func faceToRightReturnsNegativeX() {
        let offset = calculateFaceCenterOffset(faceCenterX: 0.7, faceCenterY: 0.5)
        #expect(offset.x < 0)
        #expect(abs(offset.y) < 0.001)
    }

    @Test("Face to the left returns positive X offset (mirrored)")
    func faceToLeftReturnsPositiveX() {
        let offset = calculateFaceCenterOffset(faceCenterX: 0.3, faceCenterY: 0.5)
        #expect(offset.x > 0)
        #expect(abs(offset.y) < 0.001)
    }

    @Test("Face above center returns positive Y offset")
    func faceAboveReturnsPositiveY() {
        let offset = calculateFaceCenterOffset(faceCenterX: 0.5, faceCenterY: 0.7)
        #expect(abs(offset.x) < 0.001)
        #expect(offset.y > 0)
    }

    @Test("Face below center returns negative Y offset")
    func faceBelowReturnsNegativeY() {
        let offset = calculateFaceCenterOffset(faceCenterX: 0.5, faceCenterY: 0.3)
        #expect(abs(offset.x) < 0.001)
        #expect(offset.y < 0)
    }

    @Test("Offset is clamped to max 0.3")
    func offsetIsClampedToMax() {
        // Face at extreme corner
        let offset = calculateFaceCenterOffset(faceCenterX: 1.0, faceCenterY: 1.0)
        #expect(abs(offset.x) <= 0.3)
        #expect(abs(offset.y) <= 0.3)
    }

    @Test("Offset is clamped to min -0.3")
    func offsetIsClampedToMin() {
        // Face at opposite extreme corner
        let offset = calculateFaceCenterOffset(faceCenterX: 0.0, faceCenterY: 0.0)
        #expect(abs(offset.x) <= 0.3)
        #expect(abs(offset.y) <= 0.3)
    }

    @Test("Face in top-right corner returns correct offset")
    func faceInTopRightCorner() {
        let offset = calculateFaceCenterOffset(faceCenterX: 0.8, faceCenterY: 0.8)
        #expect(offset.x < 0) // Mirrored, so right face -> negative X
        #expect(offset.y > 0) // Above center -> positive Y
    }

    @Test("Face in bottom-left corner returns correct offset")
    func faceInBottomLeftCorner() {
        let offset = calculateFaceCenterOffset(faceCenterX: 0.2, faceCenterY: 0.2)
        #expect(offset.x > 0) // Mirrored, so left face -> positive X
        #expect(offset.y < 0) // Below center -> negative Y
    }

    // Helper function that mirrors CameraManager's calculation logic
    private func calculateFaceCenterOffset(faceCenterX: CGFloat, faceCenterY: CGFloat) -> CGPoint {
        let offsetX = -(faceCenterX - 0.5)  // Negative because front camera is mirrored
        let offsetY = (faceCenterY - 0.5)

        let maxOffset: CGFloat = 0.3
        return CGPoint(
            x: max(-maxOffset, min(maxOffset, offsetX)),
            y: max(-maxOffset, min(maxOffset, offsetY))
        )
    }
}

// MARK: - Smoothing Algorithm Tests

@Suite("Eye Center Smoothing Tests")
struct EyeCenterSmoothingTests {

    @Test("Smoothing reduces sudden jumps")
    func smoothingReducesJumps() {
        var smoothedOffset = CGPoint.zero
        let newOffset = CGPoint(x: 0.3, y: 0.3)

        // Apply smoothing (same formula as CameraManager)
        smoothedOffset = CGPoint(
            x: smoothedOffset.x * 0.7 + newOffset.x * 0.3,
            y: smoothedOffset.y * 0.7 + newOffset.y * 0.3
        )

        // Result should be 30% of the new value
        #expect(abs(smoothedOffset.x - 0.09) < 0.001)
        #expect(abs(smoothedOffset.y - 0.09) < 0.001)
    }

    @Test("Smoothing converges to target over multiple frames")
    func smoothingConvergesToTarget() {
        var smoothedOffset = CGPoint.zero
        let targetOffset = CGPoint(x: 0.2, y: 0.2)

        // Apply smoothing 20 times
        for _ in 0..<20 {
            smoothedOffset = CGPoint(
                x: smoothedOffset.x * 0.7 + targetOffset.x * 0.3,
                y: smoothedOffset.y * 0.7 + targetOffset.y * 0.3
            )
        }

        // Should be very close to target after many iterations
        #expect(abs(smoothedOffset.x - targetOffset.x) < 0.01)
        #expect(abs(smoothedOffset.y - targetOffset.y) < 0.01)
    }

    @Test("Return-to-center smoothing when face lost")
    func returnToCenterSmoothing() {
        var smoothedOffset = CGPoint(x: 0.2, y: 0.2)

        // Apply return-to-center smoothing (85% decay)
        smoothedOffset = CGPoint(
            x: smoothedOffset.x * 0.85,
            y: smoothedOffset.y * 0.85
        )

        #expect(abs(smoothedOffset.x - 0.17) < 0.001)
        #expect(abs(smoothedOffset.y - 0.17) < 0.001)
    }

    @Test("Return-to-center converges to zero")
    func returnToCenterConvergesToZero() {
        var smoothedOffset = CGPoint(x: 0.3, y: 0.3)

        // Apply return-to-center smoothing 50 times
        for _ in 0..<50 {
            smoothedOffset = CGPoint(
                x: smoothedOffset.x * 0.85,
                y: smoothedOffset.y * 0.85
            )
        }

        // Should be very close to zero
        #expect(abs(smoothedOffset.x) < 0.001)
        #expect(abs(smoothedOffset.y) < 0.001)
    }
}

// MARK: - Spiral Calculation Tests

@Suite("Spiral Breathing Animation Tests")
struct SpiralBreathingTests {

    private let breathCycleSeconds: Double = 8.0
    private let breathDepth: Double = 1.0

    @Test("Breathing at start of cycle returns maximum aperture")
    func breathingAtStartReturnsMax() {
        let time: Double = 0
        let baseApertureSize: Double = 0.5

        let breathPhase = (time / breathCycleSeconds) * .pi * 2
        let breathAmount = (cos(breathPhase) + 1) / 2
        let apertureSize = baseApertureSize * (1 - breathDepth * breathAmount)

        // At time 0, cos(0) = 1, so breathAmount = 1, aperture = 0
        #expect(abs(apertureSize) < 0.001)
    }

    @Test("Breathing at half cycle returns minimum aperture (fully open)")
    func breathingAtHalfCycleReturnsMin() {
        let time: Double = 4.0 // Half of 8 second cycle
        let baseApertureSize: Double = 0.5

        let breathPhase = (time / breathCycleSeconds) * .pi * 2
        let breathAmount = (cos(breathPhase) + 1) / 2
        let apertureSize = baseApertureSize * (1 - breathDepth * breathAmount)

        // At half cycle, cos(π) = -1, so breathAmount = 0, aperture = baseApertureSize
        #expect(abs(apertureSize - baseApertureSize) < 0.001)
    }

    @Test("Breathing is periodic")
    func breathingIsPeriodic() {
        let baseApertureSize: Double = 0.5

        let aperture1 = calculateAperture(time: 0, baseApertureSize: baseApertureSize)
        let aperture2 = calculateAperture(time: 8.0, baseApertureSize: baseApertureSize)

        #expect(abs(aperture1 - aperture2) < 0.001)
    }

    @Test("Breathing varies smoothly between extremes")
    func breathingVariesSmoothly() {
        let baseApertureSize: Double = 0.5
        var previousAperture = calculateAperture(time: 0, baseApertureSize: baseApertureSize)

        // Check that aperture changes smoothly over 1 second intervals
        for i in 1...8 {
            let currentAperture = calculateAperture(time: Double(i), baseApertureSize: baseApertureSize)
            let change = abs(currentAperture - previousAperture)

            // Change per second should be gradual (less than half of base)
            #expect(change < baseApertureSize / 2)
            previousAperture = currentAperture
        }
    }

    private func calculateAperture(time: Double, baseApertureSize: Double) -> Double {
        let breathPhase = (time / breathCycleSeconds) * .pi * 2
        let breathAmount = (cos(breathPhase) + 1) / 2
        return baseApertureSize * (1 - breathDepth * breathAmount)
    }
}

// MARK: - Word Cycling Tests

@Suite("Word Cycling Tests")
struct WordCyclingTests {

    private let showFrames: Int = 15
    private let pauseFrames: Int = 30
    private var cycleLength: Int { showFrames + pauseFrames }

    @Test("Word shows during first showFrames of cycle")
    func wordShowsDuringShowFrames() {
        for frame in 0..<showFrames {
            let cyclePosition = frame % cycleLength
            let shouldShow = cyclePosition < showFrames
            #expect(shouldShow == true)
        }
    }

    @Test("Word hides during pause frames")
    func wordHidesDuringPauseFrames() {
        for frame in showFrames..<cycleLength {
            let cyclePosition = frame % cycleLength
            let shouldShow = cyclePosition < showFrames
            #expect(shouldShow == false)
        }
    }

    @Test("Cycle repeats correctly")
    func cycleRepeatsCorrectly() {
        // First cycle
        let frame1Position = 5 % cycleLength
        // Second cycle at same relative position
        let frame2Position = (cycleLength + 5) % cycleLength

        #expect(frame1Position == frame2Position)
    }

    @Test("Fade in alpha calculation")
    func fadeInAlphaCalculation() {
        // During first 3 frames, alpha fades in
        for cyclePosition in 0..<3 {
            let alpha = Double(cyclePosition) / 3.0
            #expect(alpha >= 0 && alpha < 1)
        }

        // At frame 3, should be fully visible
        let alphaAtFrame3 = Double(3) / 3.0
        #expect(abs(alphaAtFrame3 - 1.0) < 0.001)
    }

    @Test("Fade out alpha calculation")
    func fadeOutAlphaCalculation() {
        // During last 3 frames before pause, alpha fades out
        for cyclePosition in (showFrames - 3)..<showFrames {
            let alpha = Double(showFrames - cyclePosition) / 3.0
            #expect(alpha > 0 && alpha <= 1)
        }
    }

    @Test("Full visibility in middle of show period")
    func fullVisibilityInMiddle() {
        let cyclePosition = showFrames / 2

        var alpha: Double = 1
        if cyclePosition < 3 {
            alpha = Double(cyclePosition) / 3.0
        } else if cyclePosition > showFrames - 3 {
            alpha = Double(showFrames - cyclePosition) / 3.0
        }

        #expect(abs(alpha - 1.0) < 0.001)
    }
}

// MARK: - Blade Drawing Calculation Tests

@Suite("Blade Drawing Calculation Tests")
struct BladeDrawingTests {

    @Test("Blade radius increases with layer index")
    func bladeRadiusIncreasesWithLayer() {
        let baseRadius: CGFloat = 100

        let radius0 = calculateBladeRadius(baseRadius: baseRadius, layerIndex: 0)
        let radius1 = calculateBladeRadius(baseRadius: baseRadius, layerIndex: 1)
        let radius2 = calculateBladeRadius(baseRadius: baseRadius, layerIndex: 2)

        #expect(radius1 > radius0)
        #expect(radius2 > radius1)
    }

    @Test("Arc center moves inward as aperture closes")
    func arcCenterMovesInward() {
        let bladeRadius: CGFloat = 100
        let thickness: CGFloat = 12  // arbitrary thickness for testing

        let arcCenterOpen = calculateArcCenterX(bladeRadius: bladeRadius, apertureSize: 1.0, thickness: thickness)
        let arcCenterClosed = calculateArcCenterX(bladeRadius: bladeRadius, apertureSize: 0.0, thickness: thickness)

        #expect(arcCenterOpen > arcCenterClosed)
    }

    @Test("Arc radius scales with aperture size")
    func arcRadiusScalesWithAperture() {
        let bladeRadius: CGFloat = 100
        let thickness: CGFloat = 12  // arbitrary thickness for testing

        let radiusOpen = calculateArcRadius(bladeRadius: bladeRadius, apertureSize: 1.0, thickness: thickness)
        let radiusClosed = calculateArcRadius(bladeRadius: bladeRadius, apertureSize: 0.0, thickness: thickness)

        #expect(radiusOpen > radiusClosed)
    }

    @Test("Blade angles are evenly distributed")
    func bladeAnglesEvenlyDistributed() {
        let bladeCount = 9
        var angles: [Double] = []

        for i in 0..<bladeCount {
            let angle = (Double(i) / Double(bladeCount)) * .pi * 2
            angles.append(angle)
        }

        // Check spacing between consecutive blades
        let expectedSpacing = (2 * .pi) / Double(bladeCount)
        for i in 1..<bladeCount {
            let spacing = angles[i] - angles[i-1]
            #expect(abs(spacing - expectedSpacing) < 0.001)
        }
    }

    @Test("Layer alpha increases with layer index")
    func layerAlphaIncreasesWithIndex() {
        let layerCount = 5

        let alpha0 = calculateLayerAlpha(layerIndex: 0, layerCount: layerCount)
        let alpha4 = calculateLayerAlpha(layerIndex: 4, layerCount: layerCount)

        #expect(alpha4 > alpha0)
    }

    @Test("Color index wraps correctly")
    func colorIndexWrapsCorrectly() {
        let colorCount = 8

        for layer in 0..<20 {
            let colorOffset = 5 // arbitrary offset
            let colorIndex = ((layer - colorOffset) % colorCount + colorCount) % colorCount
            #expect(colorIndex >= 0 && colorIndex < colorCount)
        }
    }

    @Test("Blades converge to center point when aperture closes")
    func bladesConvergeToCenter() {
        let baseRadius: CGFloat = 100
        let layerIndex = 0  // innermost layer

        // When aperture is fully closed (0.0), blades should meet at center
        let bladeRadius = calculateBladeRadius(baseRadius: baseRadius, layerIndex: layerIndex)
        let thickness = baseRadius * (0.12 + CGFloat(layerIndex) * 0.02)
        let arcCenterX = calculateArcCenterX(bladeRadius: bladeRadius, apertureSize: 0.0, thickness: thickness)
        let arcRadius = calculateArcRadius(bladeRadius: bladeRadius, apertureSize: 0.0, thickness: thickness)
        let innerRadius = arcRadius - thickness / 2

        // The inner edge of the blade should reach the center
        // Inner edge is at: arcCenterX - innerRadius
        let innerEdgeDistance = arcCenterX - innerRadius

        // Should be at center (zero or very close)
        #expect(innerEdgeDistance < baseRadius * 0.01)
        #expect(innerEdgeDistance >= 0)  // Should not overshoot center
    }

    @Test("Blades create opening when aperture opens")
    func bladesCreateOpening() {
        let baseRadius: CGFloat = 100
        let layerIndex = 0

        // When aperture is fully open (1.0), there should be a clear opening
        let bladeRadius = calculateBladeRadius(baseRadius: baseRadius, layerIndex: layerIndex)
        let thickness = baseRadius * (0.12 + CGFloat(layerIndex) * 0.02)
        let arcCenterX = calculateArcCenterX(bladeRadius: bladeRadius, apertureSize: 1.0, thickness: thickness)
        let arcRadius = calculateArcRadius(bladeRadius: bladeRadius, apertureSize: 1.0, thickness: thickness)
        let innerRadius = arcRadius - thickness / 2

        // Inner edge should be significantly away from center
        let innerEdgeDistance = arcCenterX - innerRadius
        let openingRadius = innerEdgeDistance

        // Opening should be at least 15% of base radius
        #expect(openingRadius > baseRadius * 0.15)
    }

    // Helper functions mirroring NativeSpiralCanvas logic
    private func calculateBladeRadius(baseRadius: CGFloat, layerIndex: Int) -> CGFloat {
        return baseRadius * (0.4 + CGFloat(layerIndex) * 0.12)
    }

    private func calculateArcCenterX(bladeRadius: CGFloat, apertureSize: Double, thickness: CGFloat) -> CGFloat {
        // Updated formula for blade convergence
        let maxOpening = bladeRadius * 0.42
        let openingRadius = maxOpening * apertureSize
        let arcRadius = openingRadius + thickness / 2
        return openingRadius + arcRadius - thickness / 2  // = 2 * openingRadius
    }

    private func calculateArcRadius(bladeRadius: CGFloat, apertureSize: Double, thickness: CGFloat) -> CGFloat {
        // Updated formula for blade convergence
        let maxOpening = bladeRadius * 0.42
        let openingRadius = maxOpening * apertureSize
        return openingRadius + thickness / 2
    }

    private func calculateLayerAlpha(layerIndex: Int, layerCount: Int) -> Double {
        return 0.15 + (Double(layerIndex) / Double(layerCount)) * 0.25
    }
}

// MARK: - Hole Diameter Calculation Tests

@Suite("Hole Diameter Calculation Tests")
struct HoleDiameterTests {

    @Test("Hole diameter is zero when aperture is zero")
    func holeDiameterZeroWhenApertureClosed() {
        let radius: CGFloat = 100
        let apertureSize: Double = 0

        let holeRadius = radius * apertureSize * 0.43
        let holeDiameter = holeRadius * 2

        #expect(holeDiameter == 0)
    }

    @Test("Hole diameter scales with aperture size")
    func holeDiameterScalesWithAperture() {
        let radius: CGFloat = 100

        let diameter1 = calculateHoleDiameter(radius: radius, apertureSize: 0.25)
        let diameter2 = calculateHoleDiameter(radius: radius, apertureSize: 0.5)
        let diameter3 = calculateHoleDiameter(radius: radius, apertureSize: 1.0)

        #expect(diameter2 > diameter1)
        #expect(diameter3 > diameter2)
    }

    @Test("Max hole diameter uses base aperture size")
    func maxHoleDiameterUsesBaseAperture() {
        let radius: CGFloat = 100
        let baseApertureSize: Double = 0.5

        let maxHoleRadius = radius * baseApertureSize * 0.43
        let maxHoleDiameter = maxHoleRadius * 2

        #expect(abs(maxHoleDiameter - 43.0) < 0.001)
    }

    private func calculateHoleDiameter(radius: CGFloat, apertureSize: Double) -> CGFloat {
        let holeRadius = radius * apertureSize * 0.43
        return holeRadius * 2
    }
}

// MARK: - Gaze Detection Tests

@Suite("Gaze Detection Tests")
struct GazeDetectionTests {

    @Test("Gaze angle threshold calculation - looking straight")
    func gazeAngleStraight() {
        // When looking straight at camera: small X/Y, positive Z
        let lookAtX: Float = 0.0
        let lookAtY: Float = 0.0
        let lookAtZ: Float = 1.0

        let horizontalOffset = sqrt(lookAtX * lookAtX + lookAtY * lookAtY)
        let gazeAngle = atan2(horizontalOffset, abs(lookAtZ))

        // Angle should be near zero (looking at screen)
        #expect(gazeAngle < 0.1)
    }

    @Test("Gaze angle threshold calculation - looking away")
    func gazeAngleLookingAway() {
        // Looking 45 degrees to the side
        let lookAtX: Float = 1.0
        let lookAtY: Float = 0.0
        let lookAtZ: Float = 1.0

        let horizontalOffset = sqrt(lookAtX * lookAtX + lookAtY * lookAtY)
        let gazeAngle = atan2(horizontalOffset, abs(lookAtZ))

        // Angle should be about 45 degrees (pi/4)
        let expectedAngle: Float = .pi / 4
        #expect(abs(gazeAngle - expectedAngle) < 0.01)
    }

    @Test("Gaze angle threshold - 25 degree boundary")
    func gazeAngleThreshold() {
        let thresholdDegrees: Float = 25
        let thresholdRadians = thresholdDegrees * .pi / 180

        // Just inside threshold (24 degrees)
        let insideAngle: Float = 24 * .pi / 180
        #expect(insideAngle < thresholdRadians)

        // Just outside threshold (26 degrees)
        let outsideAngle: Float = 26 * .pi / 180
        #expect(outsideAngle > thresholdRadians)
    }

    @Test("Eye openness detection - open eye")
    func eyeOpennessOpen() {
        // Simulate eye points with significant vertical distance
        let topY: CGFloat = 0.6
        let bottomY: CGFloat = 0.4
        let verticalExtent = topY - bottomY

        let threshold: CGFloat = 0.015
        #expect(verticalExtent > threshold)
    }

    @Test("Eye openness detection - closed eye")
    func eyeOpennessClosed() {
        // Simulate eye points with minimal vertical distance (closed)
        let topY: CGFloat = 0.51
        let bottomY: CGFloat = 0.50
        let verticalExtent = topY - bottomY

        let threshold: CGFloat = 0.015
        #expect(verticalExtent < threshold)
    }

    @Test("Pupil centering - centered pupil")
    func pupilCentered() {
        // Eye spans from 0.3 to 0.5 (width = 0.2)
        let eyeMinX: CGFloat = 0.3
        let eyeMaxX: CGFloat = 0.5
        let eyeCenterX = (eyeMinX + eyeMaxX) / 2  // 0.4
        let eyeWidth = eyeMaxX - eyeMinX  // 0.2

        // Pupil at center
        let pupilX: CGFloat = 0.4
        let offsetFromCenter = abs(pupilX - eyeCenterX) / eyeWidth

        // Should be nearly zero (centered)
        #expect(offsetFromCenter < 0.3)
    }

    @Test("Pupil centering - off-center pupil (looking away)")
    func pupilOffCenter() {
        // Eye spans from 0.3 to 0.5 (width = 0.2)
        let eyeMinX: CGFloat = 0.3
        let eyeMaxX: CGFloat = 0.5
        let eyeCenterX = (eyeMinX + eyeMaxX) / 2  // 0.4
        let eyeWidth = eyeMaxX - eyeMinX  // 0.2

        // Pupil far to one side
        let pupilX: CGFloat = 0.48
        let offsetFromCenter = abs(pupilX - eyeCenterX) / eyeWidth

        // Should be significant offset (looking away)
        #expect(offsetFromCenter > 0.3)
    }

    @Test("Smoothing history - majority voting")
    func smoothingMajorityVoting() {
        // Simulate smoothing with history
        var history: [Bool] = [true, true, true, false, false]
        let historySize = 5

        // Majority is true (3 out of 5)
        let lookingCount = history.filter { $0 }.count
        let isLooking = lookingCount > historySize / 2
        #expect(isLooking == true)

        // Change to majority false
        history = [true, false, false, false, false]
        let lookingCount2 = history.filter { $0 }.count
        let isLooking2 = lookingCount2 > historySize / 2
        #expect(isLooking2 == false)
    }
}

// MARK: - Gaze-Based Freeze Logic Tests

@Suite("Gaze-Based Freeze Logic Tests")
struct GazeBasedFreezeTests {

    @Test("freezeWhenNotLooking setting default is false")
    func freezeWhenNotLookingDefault() {
        let settings = SpiralSettings(forTesting: .standard)
        #expect(settings.freezeWhenNotLooking == false)
    }

    @Test("freezeWhenNotLooking can be toggled")
    func freezeWhenNotLookingToggle() {
        let settings = SpiralSettings(forTesting: .standard)

        settings.freezeWhenNotLooking = true
        #expect(settings.freezeWhenNotLooking == true)

        settings.freezeWhenNotLooking = false
        #expect(settings.freezeWhenNotLooking == false)
    }

    @Test("Attention logic - face detected and looking")
    func attentionFaceAndLooking() {
        let faceDetected = true
        let isLookingAtScreen = true
        let freezeWhenNotLooking = true

        let hasAttention = faceDetected && (!freezeWhenNotLooking || isLookingAtScreen)
        #expect(hasAttention == true)
    }

    @Test("Attention logic - face detected but not looking (gaze enabled)")
    func attentionFaceButNotLooking() {
        let faceDetected = true
        let isLookingAtScreen = false
        let freezeWhenNotLooking = true

        let hasAttention = faceDetected && (!freezeWhenNotLooking || isLookingAtScreen)
        #expect(hasAttention == false)
    }

    @Test("Attention logic - face detected but not looking (gaze disabled)")
    func attentionFaceNotLookingGazeDisabled() {
        let faceDetected = true
        let isLookingAtScreen = false
        let freezeWhenNotLooking = false  // Gaze tracking disabled

        let hasAttention = faceDetected && (!freezeWhenNotLooking || isLookingAtScreen)
        #expect(hasAttention == true)  // Still has attention because gaze tracking is off
    }

    @Test("Attention logic - no face detected")
    func attentionNoFace() {
        let faceDetected = false
        let isLookingAtScreen = true
        let freezeWhenNotLooking = true

        let hasAttention = faceDetected && (!freezeWhenNotLooking || isLookingAtScreen)
        #expect(hasAttention == false)
    }

    @Test("Should freeze - no face with freezeWhenNoFace enabled")
    func shouldFreezeNoFace() {
        let faceDetected = false
        let isLookingAtScreen = true
        let freezeWhenNoFace = true
        let freezeWhenNotLooking = false

        let shouldFreezeOnNoFace = freezeWhenNoFace && !faceDetected
        let shouldFreezeOnNotLooking = freezeWhenNotLooking && !isLookingAtScreen
        let shouldFreeze = shouldFreezeOnNoFace || shouldFreezeOnNotLooking

        #expect(shouldFreeze == true)
    }

    @Test("Should freeze - not looking with freezeWhenNotLooking enabled")
    func shouldFreezeNotLooking() {
        let faceDetected = true
        let isLookingAtScreen = false
        let freezeWhenNoFace = false
        let freezeWhenNotLooking = true

        let shouldFreezeOnNoFace = freezeWhenNoFace && !faceDetected
        let shouldFreezeOnNotLooking = freezeWhenNotLooking && !isLookingAtScreen
        let shouldFreeze = shouldFreezeOnNoFace || shouldFreezeOnNotLooking

        #expect(shouldFreeze == true)
    }

    @Test("Should not freeze - all conditions met")
    func shouldNotFreeze() {
        let faceDetected = true
        let isLookingAtScreen = true
        let freezeWhenNoFace = true
        let freezeWhenNotLooking = true

        let shouldFreezeOnNoFace = freezeWhenNoFace && !faceDetected
        let shouldFreezeOnNotLooking = freezeWhenNotLooking && !isLookingAtScreen
        let shouldFreeze = shouldFreezeOnNoFace || shouldFreezeOnNotLooking

        #expect(shouldFreeze == false)
    }
}

// MARK: - ColorPalette Tests

@Suite("ColorPalette Tests")
struct ColorPaletteTests {

    @Test("PaletteColor initializes with RGB values")
    func paletteColorInitialization() {
        let color = PaletteColor(255, 128, 64)

        #expect(color.r == 255)
        #expect(color.g == 128)
        #expect(color.b == 64)
    }

    @Test("PaletteColor is Equatable")
    func paletteColorEquatable() {
        let color1 = PaletteColor(100, 150, 200)
        let color2 = PaletteColor(100, 150, 200)
        let color3 = PaletteColor(100, 150, 201)

        #expect(color1 == color2)
        #expect(color1 != color3)
    }

    @Test("PaletteColor is Codable")
    func paletteColorCodable() throws {
        let original = PaletteColor(123, 45, 67)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PaletteColor.self, from: data)

        #expect(decoded == original)
    }

    @Test("ColorPalette initializes with id, name, and colors")
    func colorPaletteInitialization() {
        let colors = [PaletteColor(255, 0, 0), PaletteColor(0, 255, 0)]
        let palette = ColorPalette(id: "test", name: "Test Palette", colors: colors)

        #expect(palette.id == "test")
        #expect(palette.name == "Test Palette")
        #expect(palette.colors.count == 2)
    }

    @Test("ColorPalette is Identifiable")
    func colorPaletteIdentifiable() {
        let palette = ColorPalette.warm
        let id: String = palette.id
        #expect(id == "warm")
    }

    @Test("ColorPalette is Equatable")
    func colorPaletteEquatable() {
        let palette1 = ColorPalette.warm
        let palette2 = ColorPalette.warm
        let palette3 = ColorPalette.cool

        #expect(palette1 == palette2)
        #expect(palette1 != palette3)
    }

    @Test("ColorPalette is Codable")
    func colorPaletteCodable() throws {
        let original = ColorPalette.rainbow

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ColorPalette.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
        #expect(decoded.colors.count == original.colors.count)
    }

    @Test("colorComponents returns correct tuples")
    func colorComponents() {
        let colors = [PaletteColor(100, 150, 200), PaletteColor(50, 75, 100)]
        let palette = ColorPalette(id: "test", name: "Test", colors: colors)

        let components = palette.colorComponents
        #expect(components.count == 2)
        #expect(components[0].r == 100)
        #expect(components[0].g == 150)
        #expect(components[0].b == 200)
        #expect(components[1].r == 50)
        #expect(components[1].g == 75)
        #expect(components[1].b == 100)
    }

    @Test("swiftUIColors returns correct number of colors")
    func swiftUIColors() {
        let palette = ColorPalette.warm
        let colors = palette.swiftUIColors

        #expect(colors.count == palette.colors.count)
        #expect(colors.count == 8)
    }

    @Test("All built-in palettes exist")
    func allBuiltInPalettes() {
        let palettes = ColorPalette.allBuiltIn

        #expect(palettes.count == 8)
        #expect(palettes.contains(where: { $0.id == "warm" }))
        #expect(palettes.contains(where: { $0.id == "cool" }))
        #expect(palettes.contains(where: { $0.id == "ocean" }))
        #expect(palettes.contains(where: { $0.id == "sunset" }))
        #expect(palettes.contains(where: { $0.id == "rainbow" }))
        #expect(palettes.contains(where: { $0.id == "pastel" }))
        #expect(palettes.contains(where: { $0.id == "monochrome" }))
        #expect(palettes.contains(where: { $0.id == "neon" }))
    }

    @Test("Warm palette has correct properties")
    func warmPalette() {
        let palette = ColorPalette.warm

        #expect(palette.id == "warm")
        #expect(palette.name == "Warm")
        #expect(palette.colors.count == 8)
    }

    @Test("Cool palette has correct properties")
    func coolPalette() {
        let palette = ColorPalette.cool

        #expect(palette.id == "cool")
        #expect(palette.name == "Cool")
        #expect(palette.colors.count == 8)
    }

    @Test("Ocean palette has correct properties")
    func oceanPalette() {
        let palette = ColorPalette.ocean

        #expect(palette.id == "ocean")
        #expect(palette.name == "Ocean")
        #expect(palette.colors.count == 8)
    }

    @Test("Sunset palette has correct properties")
    func sunsetPalette() {
        let palette = ColorPalette.sunset

        #expect(palette.id == "sunset")
        #expect(palette.name == "Sunset")
        #expect(palette.colors.count == 8)
    }

    @Test("Rainbow palette has correct properties")
    func rainbowPalette() {
        let palette = ColorPalette.rainbow

        #expect(palette.id == "rainbow")
        #expect(palette.name == "Rainbow")
        #expect(palette.colors.count == 8)
    }

    @Test("Pastel palette has correct properties")
    func pastelPalette() {
        let palette = ColorPalette.pastel

        #expect(palette.id == "pastel")
        #expect(palette.name == "Pastel")
        #expect(palette.colors.count == 8)
    }

    @Test("Monochrome palette has correct properties")
    func monochromePalette() {
        let palette = ColorPalette.monochrome

        #expect(palette.id == "monochrome")
        #expect(palette.name == "Monochrome")
        #expect(palette.colors.count == 8)
    }

    @Test("Neon palette has correct properties")
    func neonPalette() {
        let palette = ColorPalette.neon

        #expect(palette.id == "neon")
        #expect(palette.name == "Neon")
        #expect(palette.colors.count == 8)
    }

    @Test("Default palette is warm")
    func defaultPalette() {
        let defaultPalette = ColorPalette.default

        #expect(defaultPalette.id == "warm")
    }

    @Test("find returns correct palette for valid id")
    func findValidId() {
        let warm = ColorPalette.find(id: "warm")
        let cool = ColorPalette.find(id: "cool")
        let neon = ColorPalette.find(id: "neon")

        #expect(warm?.id == "warm")
        #expect(cool?.id == "cool")
        #expect(neon?.id == "neon")
    }

    @Test("find returns nil for invalid id")
    func findInvalidId() {
        let result = ColorPalette.find(id: "nonexistent")

        #expect(result == nil)
    }

    @Test("find returns nil for empty id")
    func findEmptyId() {
        let result = ColorPalette.find(id: "")

        #expect(result == nil)
    }
}

// MARK: - Preset XML Serialization Tests

@Suite("Preset XML Serialization Tests")
struct PresetXMLSerializationTests {

    @Test("toXML generates valid XML structure")
    func toXMLValidStructure() {
        let preset = Preset(
            name: "Test Preset",
            bladeCount: 10,
            layerCount: 4,
            speed: 1.5,
            apertureSize: 0.6,
            phrases: ["Hello", "World"]
        )

        let xml = preset.toXML()

        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(xml.contains("<preset>"))
        #expect(xml.contains("</preset>"))
        #expect(xml.contains("<name>Test Preset</name>"))
        #expect(xml.contains("<bladeCount>10</bladeCount>"))
        #expect(xml.contains("<layerCount>4</layerCount>"))
        #expect(xml.contains("<speed>1.5</speed>"))
        #expect(xml.contains("<apertureSize>0.6</apertureSize>"))
        #expect(xml.contains("<phrases>"))
        #expect(xml.contains("<phrase>Hello</phrase>"))
        #expect(xml.contains("<phrase>World</phrase>"))
    }

    @Test("toXML includes all properties")
    func toXMLIncludesAllProperties() {
        let preset = Preset(
            name: "Full Preset",
            bladeCount: 12,
            layerCount: 6,
            speed: 2.0,
            apertureSize: 0.4,
            phrases: ["A"],
            phraseDisplayDuration: 15,
            previewOnly: true,
            colorFlowSpeed: 1.2,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 1,
            eyeCenteringEnabled: false,
            freezeWhenNoFace: true,
            freezeWhenNotLooking: true,
            colorPaletteId: "cool"
        )

        let xml = preset.toXML()

        #expect(xml.contains("<phraseDisplayDuration>15</phraseDisplayDuration>"))
        #expect(xml.contains("<previewOnly>true</previewOnly>"))
        #expect(xml.contains("<colorFlowSpeed>1.2</colorFlowSpeed>"))
        #expect(xml.contains("<mirrorAlwaysOn>true</mirrorAlwaysOn>"))
        #expect(xml.contains("<mirrorAnimationMode>1</mirrorAnimationMode>"))
        #expect(xml.contains("<eyeCenteringEnabled>false</eyeCenteringEnabled>"))
        #expect(xml.contains("<freezeWhenNoFace>true</freezeWhenNoFace>"))
        #expect(xml.contains("<freezeWhenNotLooking>true</freezeWhenNotLooking>"))
        #expect(xml.contains("<colorPaletteId>cool</colorPaletteId>"))
    }

    @Test("toXML escapes special XML characters in name")
    func toXMLEscapesName() {
        let preset = Preset(
            name: "Test <>&\"' Name",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: []
        )

        let xml = preset.toXML()

        #expect(xml.contains("Test &lt;&gt;&amp;&quot;&apos; Name"))
    }

    @Test("toXML escapes special XML characters in phrases")
    func toXMLEscapesPhrases() {
        let preset = Preset(
            name: "Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["Hello <World>", "A & B"]
        )

        let xml = preset.toXML()

        #expect(xml.contains("<phrase>Hello &lt;World&gt;</phrase>"))
        #expect(xml.contains("<phrase>A &amp; B</phrase>"))
    }

    @Test("toXML includes preset ID")
    func toXMLIncludesId() {
        let preset = Preset(
            name: "Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: []
        )

        let xml = preset.toXML()

        #expect(xml.contains("<id>\(preset.id.uuidString)</id>"))
    }

    @Test("fromXML parses valid XML")
    func fromXMLParsesValid() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <preset>
          <id>12345678-1234-1234-1234-123456789ABC</id>
          <name>Parsed Preset</name>
          <bladeCount>8</bladeCount>
          <layerCount>3</layerCount>
          <speed>0.75</speed>
          <apertureSize>0.8</apertureSize>
          <phrases>
            <phrase>First</phrase>
            <phrase>Second</phrase>
          </phrases>
          <phraseDisplayDuration>10</phraseDisplayDuration>
          <previewOnly>true</previewOnly>
          <colorFlowSpeed>0.9</colorFlowSpeed>
          <mirrorAlwaysOn>true</mirrorAlwaysOn>
          <mirrorAnimationMode>2</mirrorAnimationMode>
          <eyeCenteringEnabled>false</eyeCenteringEnabled>
          <freezeWhenNoFace>true</freezeWhenNoFace>
          <freezeWhenNotLooking>true</freezeWhenNotLooking>
          <colorPaletteId>ocean</colorPaletteId>
        </preset>
        """

        let preset = Preset.fromXML(xml)

        #expect(preset != nil)
        #expect(preset?.name == "Parsed Preset")
        #expect(preset?.bladeCount == 8)
        #expect(preset?.layerCount == 3)
        #expect(preset?.speed == 0.75)
        #expect(preset?.apertureSize == 0.8)
        #expect(preset?.phrases == ["First", "Second"])
        #expect(preset?.phraseDisplayDuration == 10)
        #expect(preset?.previewOnly == true)
        #expect(preset?.colorFlowSpeed == 0.9)
        #expect(preset?.mirrorAlwaysOn == true)
        #expect(preset?.mirrorAnimationMode == 2)
        #expect(preset?.eyeCenteringEnabled == false)
        #expect(preset?.freezeWhenNoFace == true)
        #expect(preset?.freezeWhenNotLooking == true)
        #expect(preset?.colorPaletteId == "ocean")
    }

    @Test("fromXML uses defaults for missing optional fields")
    func fromXMLDefaultsForMissing() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <preset>
          <name>Minimal Preset</name>
          <bladeCount>9</bladeCount>
          <layerCount>5</layerCount>
          <speed>1.0</speed>
          <apertureSize>0.5</apertureSize>
          <phrases></phrases>
        </preset>
        """

        let preset = Preset.fromXML(xml)

        #expect(preset != nil)
        #expect(preset?.phraseDisplayDuration == 2.0)
        #expect(preset?.previewOnly == false)
        #expect(preset?.colorFlowSpeed == 0.5)
        #expect(preset?.mirrorAlwaysOn == false)
        #expect(preset?.mirrorAnimationMode == 2) // Defaults to 2 (Both)
        #expect(preset?.eyeCenteringEnabled == true)
        #expect(preset?.freezeWhenNoFace == false)
        #expect(preset?.freezeWhenNotLooking == false)
        #expect(preset?.colorPaletteId == "warm")
    }

    @Test("fromXML normalizes legacy mirrorAnimationMode 0 to 1")
    func fromXMLNormalizesLegacyMode() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <preset>
          <name>Legacy</name>
          <bladeCount>9</bladeCount>
          <layerCount>5</layerCount>
          <speed>1.0</speed>
          <apertureSize>0.5</apertureSize>
          <phrases></phrases>
          <mirrorAnimationMode>0</mirrorAnimationMode>
        </preset>
        """

        let preset = Preset.fromXML(xml)

        #expect(preset?.mirrorAnimationMode == 1)
    }

    @Test("fromXML returns nil for invalid XML")
    func fromXMLInvalidXML() {
        let xml = "This is not XML"

        let preset = Preset.fromXML(xml)

        #expect(preset == nil)
    }

    @Test("fromXML returns nil for missing required fields")
    func fromXMLMissingRequired() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <preset>
          <name>Incomplete</name>
          <bladeCount>9</bladeCount>
        </preset>
        """

        let preset = Preset.fromXML(xml)

        #expect(preset == nil)
    }

    @Test("fromXML returns nil for empty string")
    func fromXMLEmptyString() {
        let preset = Preset.fromXML("")

        #expect(preset == nil)
    }

    @Test("XML roundtrip preserves all data")
    func xmlRoundtrip() {
        let original = Preset(
            name: "Roundtrip Test",
            bladeCount: 11,
            layerCount: 7,
            speed: 1.8,
            apertureSize: 0.45,
            phrases: ["Alpha", "Beta", "Gamma"],
            phraseDisplayDuration: 20,
            previewOnly: true,
            colorFlowSpeed: 1.5,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 1,
            eyeCenteringEnabled: false,
            freezeWhenNoFace: true,
            freezeWhenNotLooking: true,
            colorPaletteId: "sunset"
        )

        let xml = original.toXML()
        let parsed = Preset.fromXML(xml)

        #expect(parsed != nil)
        #expect(parsed?.id == original.id)
        #expect(parsed?.name == original.name)
        #expect(parsed?.bladeCount == original.bladeCount)
        #expect(parsed?.layerCount == original.layerCount)
        #expect(abs((parsed?.speed ?? 0) - original.speed) < 0.001)
        #expect(abs((parsed?.apertureSize ?? 0) - original.apertureSize) < 0.001)
        #expect(parsed?.phrases == original.phrases)
        #expect(parsed?.phraseDisplayDuration == original.phraseDisplayDuration)
        #expect(parsed?.previewOnly == original.previewOnly)
        #expect(abs((parsed?.colorFlowSpeed ?? 0) - original.colorFlowSpeed) < 0.001)
        #expect(parsed?.mirrorAlwaysOn == original.mirrorAlwaysOn)
        #expect(parsed?.mirrorAnimationMode == original.mirrorAnimationMode)
        #expect(parsed?.eyeCenteringEnabled == original.eyeCenteringEnabled)
        #expect(parsed?.freezeWhenNoFace == original.freezeWhenNoFace)
        #expect(parsed?.freezeWhenNotLooking == original.freezeWhenNotLooking)
        #expect(parsed?.colorPaletteId == original.colorPaletteId)
    }

    @Test("XML roundtrip with special characters")
    func xmlRoundtripSpecialChars() {
        let original = Preset(
            name: "Test <Name> & \"Quotes\"",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["Hello <World>", "A & B", "\"Quoted\""]
        )

        let xml = original.toXML()
        let parsed = Preset.fromXML(xml)

        #expect(parsed?.name == original.name)
        #expect(parsed?.phrases == original.phrases)
    }

    @Test("fromXML handles empty phrases")
    func fromXMLEmptyPhrases() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <preset>
          <name>No Phrases</name>
          <bladeCount>9</bladeCount>
          <layerCount>5</layerCount>
          <speed>1.0</speed>
          <apertureSize>0.5</apertureSize>
          <phrases></phrases>
        </preset>
        """

        let preset = Preset.fromXML(xml)

        #expect(preset != nil)
        // Empty phrases should default to [""] per implementation
        #expect(preset?.phrases == [""])
    }

    @Test("fromXML preserves UUID when valid")
    func fromXMLPreservesUUID() {
        let testUUID = UUID()
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <preset>
          <id>\(testUUID.uuidString)</id>
          <name>Test</name>
          <bladeCount>9</bladeCount>
          <layerCount>5</layerCount>
          <speed>1.0</speed>
          <apertureSize>0.5</apertureSize>
          <phrases><phrase>Test</phrase></phrases>
        </preset>
        """

        let preset = Preset.fromXML(xml)

        #expect(preset?.id == testUUID)
    }

    @Test("fromXML generates new UUID for invalid id")
    func fromXMLGeneratesUUIDForInvalid() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <preset>
          <id>not-a-valid-uuid</id>
          <name>Test</name>
          <bladeCount>9</bladeCount>
          <layerCount>5</layerCount>
          <speed>1.0</speed>
          <apertureSize>0.5</apertureSize>
          <phrases><phrase>Test</phrase></phrases>
        </preset>
        """

        let preset = Preset.fromXML(xml)

        #expect(preset != nil)
        // Should have a valid UUID even if input was invalid
        #expect(preset?.id != nil)
    }
}

// MARK: - PresetManager Import/Export Tests

@Suite("PresetManager Import/Export Tests")
struct PresetManagerImportExportTests {

    func createTestUserDefaults() -> UserDefaults {
        let suiteName = "com.evelynspiral.importexporttests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }

    @Test("importPreset creates preset from valid XML")
    func importPresetValid() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <preset>
          <name>Imported Preset</name>
          <bladeCount>10</bladeCount>
          <layerCount>4</layerCount>
          <speed>1.5</speed>
          <apertureSize>0.6</apertureSize>
          <phrases>
            <phrase>Hello</phrase>
          </phrases>
        </preset>
        """

        let imported = manager.importPreset(from: xml)

        #expect(imported != nil)
        #expect(imported?.name == "Imported Preset")
        #expect(manager.userPresets.count == 1)
    }

    @Test("importPreset generates new UUID for imported preset")
    func importPresetGeneratesNewUUID() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        let originalUUID = UUID()
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <preset>
          <id>\(originalUUID.uuidString)</id>
          <name>Imported</name>
          <bladeCount>9</bladeCount>
          <layerCount>5</layerCount>
          <speed>1.0</speed>
          <apertureSize>0.5</apertureSize>
          <phrases><phrase>Test</phrase></phrases>
        </preset>
        """

        let imported = manager.importPreset(from: xml)

        #expect(imported != nil)
        #expect(imported?.id != originalUUID) // Should have new UUID
    }

    @Test("importPreset returns nil for invalid XML")
    func importPresetInvalid() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        let imported = manager.importPreset(from: "not valid xml")

        #expect(imported == nil)
        #expect(manager.userPresets.isEmpty)
    }

    @Test("importPreset adds to existing user presets")
    func importPresetAddsToExisting() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        // Add an existing preset
        let existing = Preset(name: "Existing", bladeCount: 9, layerCount: 5, speed: 1.0, apertureSize: 0.5, phrases: [])
        manager.userPresets.append(existing)

        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <preset>
          <name>New Import</name>
          <bladeCount>10</bladeCount>
          <layerCount>4</layerCount>
          <speed>1.5</speed>
          <apertureSize>0.6</apertureSize>
          <phrases><phrase>Test</phrase></phrases>
        </preset>
        """

        let imported = manager.importPreset(from: xml)

        #expect(imported != nil)
        #expect(manager.userPresets.count == 2)
    }

    @Test("exportPresetURL creates file with XML content")
    func exportPresetURLCreatesFile() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        let preset = Preset(
            name: "Export Test",
            bladeCount: 10,
            layerCount: 4,
            speed: 1.5,
            apertureSize: 0.6,
            phrases: ["Hello"]
        )

        let url = manager.exportPresetURL(preset)

        #expect(url != nil)
        #expect(FileManager.default.fileExists(atPath: url!.path))

        // Cleanup
        try? FileManager.default.removeItem(at: url!)
    }

    @Test("exportPresetURL creates file with correct name")
    func exportPresetURLCorrectName() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        let preset = Preset(
            name: "My Preset",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: []
        )

        let url = manager.exportPresetURL(preset)

        #expect(url?.lastPathComponent == "My_Preset.xml")

        // Cleanup
        if let url = url {
            try? FileManager.default.removeItem(at: url)
        }
    }

    @Test("exportPresetURL file contains valid XML")
    func exportPresetURLValidXML() throws {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        let preset = Preset(
            name: "Export Valid",
            bladeCount: 10,
            layerCount: 4,
            speed: 1.5,
            apertureSize: 0.6,
            phrases: ["Test Phrase"]
        )

        let url = manager.exportPresetURL(preset)!
        let content = try String(contentsOf: url, encoding: .utf8)

        #expect(content.contains("<?xml"))
        #expect(content.contains("<preset>"))
        #expect(content.contains("<name>Export Valid</name>"))
        #expect(content.contains("<phrase>Test Phrase</phrase>"))

        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }

    @Test("Export then import roundtrip preserves preset")
    func exportImportRoundtrip() throws {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        let original = Preset(
            name: "Roundtrip",
            bladeCount: 11,
            layerCount: 6,
            speed: 1.8,
            apertureSize: 0.45,
            phrases: ["One", "Two"],
            phraseDisplayDuration: 5,
            previewOnly: true,
            colorFlowSpeed: 1.2,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 1,
            eyeCenteringEnabled: false,
            freezeWhenNoFace: true,
            freezeWhenNotLooking: true,
            colorPaletteId: "neon"
        )

        // Export
        let url = manager.exportPresetURL(original)!
        let xmlContent = try String(contentsOf: url, encoding: .utf8)

        // Import
        let imported = manager.importPreset(from: xmlContent)

        #expect(imported != nil)
        #expect(imported?.name == original.name)
        #expect(imported?.bladeCount == original.bladeCount)
        #expect(imported?.layerCount == original.layerCount)
        #expect(abs((imported?.speed ?? 0) - original.speed) < 0.001)
        #expect(abs((imported?.apertureSize ?? 0) - original.apertureSize) < 0.001)
        #expect(imported?.phrases == original.phrases)
        #expect(imported?.phraseDisplayDuration == original.phraseDisplayDuration)
        #expect(imported?.previewOnly == original.previewOnly)
        #expect(abs((imported?.colorFlowSpeed ?? 0) - original.colorFlowSpeed) < 0.001)
        #expect(imported?.mirrorAlwaysOn == original.mirrorAlwaysOn)
        #expect(imported?.mirrorAnimationMode == original.mirrorAnimationMode)
        #expect(imported?.eyeCenteringEnabled == original.eyeCenteringEnabled)
        #expect(imported?.freezeWhenNoFace == original.freezeWhenNoFace)
        #expect(imported?.freezeWhenNotLooking == original.freezeWhenNotLooking)
        #expect(imported?.colorPaletteId == original.colorPaletteId)

        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }
}

// MARK: - SpiralSettings Additional Tests

@Suite("SpiralSettings Additional Tests")
struct SpiralSettingsAdditionalTests {

    @Test("eyeCenteringEnabled default is true")
    func eyeCenteringEnabledDefault() {
        let settings = SpiralSettings(forTesting: .standard)

        #expect(settings.eyeCenteringEnabled == true)
    }

    @Test("eyeCenteringEnabled can be modified")
    func eyeCenteringEnabledModification() {
        let settings = SpiralSettings(forTesting: .standard)

        settings.eyeCenteringEnabled = false
        #expect(settings.eyeCenteringEnabled == false)

        settings.eyeCenteringEnabled = true
        #expect(settings.eyeCenteringEnabled == true)
    }

    @Test("colorPaletteId default is warm")
    func colorPaletteIdDefault() {
        let settings = SpiralSettings(forTesting: .standard)

        #expect(settings.colorPaletteId == "warm")
    }

    @Test("colorPaletteId can be modified")
    func colorPaletteIdModification() {
        let settings = SpiralSettings(forTesting: .standard)

        settings.colorPaletteId = "cool"
        #expect(settings.colorPaletteId == "cool")

        settings.colorPaletteId = "neon"
        #expect(settings.colorPaletteId == "neon")
    }

    @Test("colorPalette returns correct palette for colorPaletteId")
    func colorPaletteReturnsCorrect() {
        let settings = SpiralSettings(forTesting: .standard)

        settings.colorPaletteId = "warm"
        #expect(settings.colorPalette.id == "warm")

        settings.colorPaletteId = "cool"
        #expect(settings.colorPalette.id == "cool")

        settings.colorPaletteId = "ocean"
        #expect(settings.colorPalette.id == "ocean")
    }

    @Test("colorPalette returns default for invalid colorPaletteId")
    func colorPaletteReturnsDefaultForInvalid() {
        let settings = SpiralSettings(forTesting: .standard)

        settings.colorPaletteId = "nonexistent"
        #expect(settings.colorPalette.id == "warm") // Default
    }

    @Test("spiralFrozen default is false")
    func spiralFrozenDefault() {
        let settings = SpiralSettings(forTesting: .standard)

        #expect(settings.spiralFrozen == false)
    }

    @Test("spiralFrozen can be modified")
    func spiralFrozenModification() {
        let settings = SpiralSettings(forTesting: .standard)

        settings.spiralFrozen = true
        #expect(settings.spiralFrozen == true)

        settings.spiralFrozen = false
        #expect(settings.spiralFrozen == false)
    }

    @Test("applyPreset updates all properties including new ones")
    func applyPresetUpdatesAll() {
        let settings = SpiralSettings(forTesting: .standard)

        let preset = Preset(
            name: "Full Test",
            bladeCount: 12,
            layerCount: 7,
            speed: 2.2,
            apertureSize: 0.35,
            phrases: ["Test", "Preset"],
            phraseDisplayDuration: 10,
            previewOnly: true,
            colorFlowSpeed: 1.8,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 1,
            eyeCenteringEnabled: false,
            freezeWhenNoFace: true,
            freezeWhenNotLooking: true,
            colorPaletteId: "sunset"
        )

        settings.applyPreset(preset)

        #expect(settings.bladeCount == 12)
        #expect(settings.layerCount == 7)
        #expect(abs(settings.speed - 2.2) < 0.001)
        #expect(abs(settings.apertureSize - 0.35) < 0.001)
        #expect(settings.phrases == ["Test", "Preset"])
        #expect(settings.phraseDisplayDuration == 10)
        #expect(settings.previewOnly == true)
        #expect(abs(settings.colorFlowSpeed - 1.8) < 0.001)
        #expect(settings.mirrorAlwaysOn == true)
        #expect(settings.mirrorAnimationMode == 1)
        #expect(settings.eyeCenteringEnabled == false)
        #expect(settings.freezeWhenNoFace == true)
        #expect(settings.freezeWhenNotLooking == true)
        #expect(settings.colorPaletteId == "sunset")
    }

    @Test("applyPreset normalizes legacy mirrorAnimationMode 0 to 1")
    func applyPresetNormalizesLegacyMode() {
        let settings = SpiralSettings(forTesting: .standard)

        let preset = Preset(
            name: "Legacy",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: [],
            mirrorAnimationMode: 0 // Legacy value
        )

        settings.applyPreset(preset)

        #expect(settings.mirrorAnimationMode == 1) // Should be normalized to 1
    }

    @Test("reset restores all properties including new ones")
    func resetRestoresAll() {
        let settings = SpiralSettings(forTesting: .standard)

        // Change all properties
        settings.bladeCount = 20
        settings.eyeCenteringEnabled = false
        settings.freezeWhenNoFace = true
        settings.freezeWhenNotLooking = true
        settings.colorPaletteId = "neon"
        settings.colorByBlade = true

        settings.reset()

        #expect(settings.bladeCount == 9)
        #expect(settings.eyeCenteringEnabled == true)
        #expect(settings.freezeWhenNoFace == false)
        #expect(settings.freezeWhenNotLooking == false)
        #expect(settings.colorPaletteId == "warm")
        #expect(settings.colorByBlade == false)
    }

    @Test("colorByBlade default is false")
    func colorByBladeDefault() {
        let settings = SpiralSettings(forTesting: .standard)

        #expect(settings.colorByBlade == false)
    }

    @Test("colorByBlade can be modified")
    func colorByBladeModification() {
        let settings = SpiralSettings(forTesting: .standard)

        settings.colorByBlade = true
        #expect(settings.colorByBlade == true)

        settings.colorByBlade = false
        #expect(settings.colorByBlade == false)
    }

    @Test("phrasesText with only whitespace lines filters to non-empty")
    func phrasesTextWhitespaceOnly() {
        let settings = SpiralSettings(forTesting: .standard)

        // phrasesText setter splits by newlines but doesn't trim individual lines
        // Only empty strings (after splitting) are filtered
        settings.phrasesText = "\n\n\n"

        #expect(settings.phrases.isEmpty)
    }

    @Test("phrasesText preserves phrase content")
    func phrasesTextPreservesContent() {
        let settings = SpiralSettings(forTesting: .standard)

        settings.phrasesText = "Hello World\nGoodbye World"

        #expect(settings.phrases == ["Hello World", "Goodbye World"])
    }
}

// MARK: - Preset matchesSettings Full Tests

@Suite("Preset matchesSettings Full Tests")
struct PresetMatchesSettingsFullTests {

    @Test("matchesSettings returns true for exact match with all new properties")
    func matchesSettingsExactMatch() {
        let preset = Preset(
            name: "Test",
            bladeCount: 10,
            layerCount: 5,
            speed: 1.5,
            apertureSize: 0.6,
            phrases: ["Hello"],
            phraseDisplayDuration: 5,
            previewOnly: true,
            colorFlowSpeed: 1.2,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 1,
            eyeCenteringEnabled: false,
            freezeWhenNoFace: true,
            freezeWhenNotLooking: true,
            colorPaletteId: "cool",
            colorByBlade: true
        )

        let matches = preset.matchesSettings(
            bladeCount: 10,
            layerCount: 5,
            speed: 1.5,
            apertureSize: 0.6,
            phrases: ["Hello"],
            phraseDisplayDuration: 5,
            previewOnly: true,
            colorFlowSpeed: 1.2,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 1,
            eyeCenteringEnabled: false,
            freezeWhenNoFace: true,
            freezeWhenNotLooking: true,
            colorPaletteId: "cool",
            colorByBlade: true
        )

        #expect(matches == true)
    }

    @Test("matchesSettings returns false for different eyeCenteringEnabled")
    func matchesSettingsDifferentEyeCentering() {
        let preset = Preset(
            name: "Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: [],
            eyeCenteringEnabled: true
        )

        let matches = preset.matchesSettings(
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: [],
            phraseDisplayDuration: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: false,
            mirrorAnimationMode: 2,
            eyeCenteringEnabled: false, // Different
            freezeWhenNoFace: false,
            freezeWhenNotLooking: false,
            colorPaletteId: "warm",
            colorByBlade: false
        )

        #expect(matches == false)
    }

    @Test("matchesSettings returns false for different freezeWhenNoFace")
    func matchesSettingsDifferentFreezeNoFace() {
        let preset = Preset(
            name: "Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: [],
            freezeWhenNoFace: true
        )

        let matches = preset.matchesSettings(
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: [],
            phraseDisplayDuration: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: false,
            mirrorAnimationMode: 2,
            eyeCenteringEnabled: true,
            freezeWhenNoFace: false, // Different
            freezeWhenNotLooking: false,
            colorPaletteId: "warm",
            colorByBlade: false
        )

        #expect(matches == false)
    }

    @Test("matchesSettings returns false for different freezeWhenNotLooking")
    func matchesSettingsDifferentFreezeNotLooking() {
        let preset = Preset(
            name: "Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: [],
            freezeWhenNotLooking: true
        )

        let matches = preset.matchesSettings(
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: [],
            phraseDisplayDuration: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: false,
            mirrorAnimationMode: 2,
            eyeCenteringEnabled: true,
            freezeWhenNoFace: false,
            freezeWhenNotLooking: false, // Different
            colorPaletteId: "warm",
            colorByBlade: false
        )

        #expect(matches == false)
    }

    @Test("matchesSettings returns false for different colorPaletteId")
    func matchesSettingsDifferentColorPalette() {
        let preset = Preset(
            name: "Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: [],
            colorPaletteId: "warm"
        )

        let matches = preset.matchesSettings(
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: [],
            phraseDisplayDuration: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: false,
            mirrorAnimationMode: 2,
            eyeCenteringEnabled: true,
            freezeWhenNoFace: false,
            freezeWhenNotLooking: false,
            colorPaletteId: "cool", // Different
            colorByBlade: false
        )

        #expect(matches == false)
    }

    @Test("matchesSettings returns false for different colorByBlade")
    func matchesSettingsDifferentColorByBlade() {
        let preset = Preset(
            name: "Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: [],
            colorByBlade: true
        )

        let matches = preset.matchesSettings(
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: [],
            phraseDisplayDuration: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: false,
            mirrorAnimationMode: 2,
            eyeCenteringEnabled: true,
            freezeWhenNoFace: false,
            freezeWhenNotLooking: false,
            colorPaletteId: "warm",
            colorByBlade: false // Different
        )

        #expect(matches == false)
    }

    @Test("matchesSettings uses tolerance for double comparisons")
    func matchesSettingsDoubleTolerance() {
        let preset = Preset(
            name: "Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: [],
            colorFlowSpeed: 1.0
        )

        // Values within 0.01 tolerance should match
        let matches = preset.matchesSettings(
            bladeCount: 9,
            layerCount: 5,
            speed: 1.005, // Within tolerance
            apertureSize: 0.505, // Within tolerance
            phrases: [],
            phraseDisplayDuration: 0,
            previewOnly: false,
            colorFlowSpeed: 1.005, // Within tolerance
            mirrorAlwaysOn: false,
            mirrorAnimationMode: 2,
            eyeCenteringEnabled: true,
            freezeWhenNoFace: false,
            freezeWhenNotLooking: false,
            colorPaletteId: "warm",
            colorByBlade: false
        )

        #expect(matches == true)
    }
}

// MARK: - GazeTrackerFactory Tests

@Suite("GazeTrackerFactory Tests")
struct GazeTrackerFactoryTests {

    @Test("create returns VisionGazeTracker")
    func createReturnsVisionTracker() {
        let tracker = GazeTrackerFactory.create()

        #expect(tracker is VisionGazeTracker)
    }

    @Test("isARKitSupported returns boolean")
    func isARKitSupportedReturnsBool() {
        // Just verify it returns a boolean without crashing
        let supported = GazeTrackerFactory.isARKitSupported
        _ = supported // Use the value
    }

    @Test("VisionGazeTracker starts with isLookingAtScreen true")
    func visionTrackerInitialState() {
        let tracker = VisionGazeTracker()

        #expect(tracker.isLookingAtScreen == true)
    }

    @Test("VisionGazeTracker start resets state")
    func visionTrackerStartResetsState() {
        let tracker = VisionGazeTracker()

        tracker.start()

        #expect(tracker.isLookingAtScreen == true)
    }

    @Test("VisionGazeTracker stop resets state")
    func visionTrackerStopResetsState() {
        let tracker = VisionGazeTracker()

        tracker.stop()

        #expect(tracker.isLookingAtScreen == true)
    }

    @Test("VisionGazeTracker onGazeUpdate callback can be set")
    func visionTrackerCallbackCanBeSet() {
        let tracker = VisionGazeTracker()
        var callbackCalled = false

        tracker.onGazeUpdate = { _ in
            callbackCalled = true
        }

        #expect(tracker.onGazeUpdate != nil)
    }

    @Test("ARKitGazeTracker starts with isLookingAtScreen true")
    func arkitTrackerInitialState() {
        let tracker = ARKitGazeTracker()

        #expect(tracker.isLookingAtScreen == true)
    }

    @Test("ARKitGazeTracker stop resets state")
    func arkitTrackerStopResetsState() {
        let tracker = ARKitGazeTracker()

        tracker.stop()

        #expect(tracker.isLookingAtScreen == true)
    }

    @Test("ARKitGazeTracker onGazeUpdate callback can be set")
    func arkitTrackerCallbackCanBeSet() {
        let tracker = ARKitGazeTracker()
        var callbackCalled = false

        tracker.onGazeUpdate = { _ in
            callbackCalled = true
        }

        #expect(tracker.onGazeUpdate != nil)
    }
}

// MARK: - PresetManager detectCurrentPreset Tests

@Suite("PresetManager detectCurrentPreset Tests")
struct PresetManagerDetectCurrentPresetTests {

    func createTestUserDefaults() -> UserDefaults {
        let suiteName = "com.evelynspiral.detecttests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }

    @Test("detectCurrentPreset finds matching built-in preset")
    func detectFindsBuiltIn() {
        let defaults = createTestUserDefaults()
        let settings = SpiralSettings(forTesting: defaults)
        let manager = PresetManager(forTesting: defaults, settings: settings)

        // Apply Birthday preset
        let birthday = manager.builtInPresets[0]
        manager.applyPreset(birthday)

        manager.currentPresetId = nil // Clear for detection test
        manager.detectCurrentPreset()

        #expect(manager.currentPresetId == birthday.id)
    }

    @Test("detectCurrentPreset finds matching user preset")
    func detectFindsUserPreset() {
        let defaults = createTestUserDefaults()
        let settings = SpiralSettings(forTesting: defaults)
        let manager = PresetManager(forTesting: defaults, settings: settings)

        // Create and add a user preset
        let userPreset = Preset(
            name: "User Preset",
            bladeCount: 11,
            layerCount: 6,
            speed: 1.7,
            apertureSize: 0.55,
            phrases: ["Custom"],
            phraseDisplayDuration: 3,
            previewOnly: true,
            colorFlowSpeed: 0.8,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 1,
            eyeCenteringEnabled: false,
            freezeWhenNoFace: true,
            freezeWhenNotLooking: false,
            colorPaletteId: "ocean"
        )
        manager.userPresets.append(userPreset)
        manager.applyPreset(userPreset)

        manager.currentPresetId = nil // Clear for detection test
        manager.detectCurrentPreset()

        #expect(manager.currentPresetId == userPreset.id)
    }

    @Test("detectCurrentPreset sets nil when no match")
    func detectSetsNilWhenNoMatch() {
        let defaults = createTestUserDefaults()
        let settings = SpiralSettings(forTesting: defaults)
        let manager = PresetManager(forTesting: defaults, settings: settings)

        // Set unique settings that don't match any preset
        settings.bladeCount = 99
        settings.layerCount = 99
        settings.speed = 99.0
        settings.apertureSize = 0.99
        settings.phrases = ["Unique Phrase That Matches Nothing"]

        manager.currentPresetId = UUID() // Set some value
        manager.detectCurrentPreset()

        #expect(manager.currentPresetId == nil)
    }
}

// MARK: - PresetManager Built-in Presets Tests (Expanded)

@Suite("PresetManager Built-in Presets Expanded Tests")
struct PresetManagerBuiltInExpandedTests {

    func createTestUserDefaults() -> UserDefaults {
        let suiteName = "com.evelynspiral.builtintests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }

    @Test("Trippy preset exists and has correct values")
    func trippyPresetValues() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        #expect(manager.builtInPresets.count == 4) // Updated count with Trippy

        let trippy = manager.builtInPresets.first { $0.name == "Trippy" }
        #expect(trippy != nil)
        #expect(trippy?.bladeCount == 12)
        #expect(trippy?.layerCount == 6)
        #expect(trippy?.speed == 1.5)
        #expect(trippy?.apertureSize == 0.4)
        #expect(trippy?.phrases == ["Whoa", "Dude", "Vibrate", "What's Happening?", "Drift"])
        #expect(trippy?.mirrorAnimationMode == 1)
        #expect(trippy?.colorPaletteId == "earth")
    }

    @Test("All built-in presets have colorPaletteId set")
    func allBuiltInHaveColorPalette() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        for preset in manager.builtInPresets {
            #expect(!preset.colorPaletteId.isEmpty, "Preset \(preset.name) should have colorPaletteId")
        }
    }

    @Test("allPresets includes both built-in and user presets")
    func allPresetsIncludesBoth() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)

        let userPreset = Preset(name: "User", bladeCount: 9, layerCount: 5, speed: 1.0, apertureSize: 0.5, phrases: [])
        manager.userPresets.append(userPreset)

        #expect(manager.allPresets.count == 5) // 4 built-in + 1 user
        #expect(manager.allPresets.contains(where: { $0.name == "User" }))
        #expect(manager.allPresets.contains(where: { $0.name == "Birthday" }))
    }
}

// MARK: - PresetManager saveCurrentAsPreset Tests

@Suite("PresetManager saveCurrentAsPreset Tests")
struct PresetManagerSaveCurrentAsPresetTests {

    func createTestUserDefaults() -> UserDefaults {
        let suiteName = "com.evelynspiral.savetests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }

    @Test("saveCurrentAsPreset creates preset with current settings")
    @MainActor
    func saveCreatesPreset() async {
        let defaults = createTestUserDefaults()
        let settings = SpiralSettings(forTesting: defaults)
        let manager = PresetManager(forTesting: defaults, settings: settings)

        settings.bladeCount = 15
        settings.layerCount = 7
        settings.speed = 2.0
        settings.apertureSize = 0.4
        settings.phrases = ["Save", "Test"]
        settings.colorPaletteId = "neon"
        settings.eyeCenteringEnabled = false

        manager.saveCurrentAsPreset(name: "Saved Preset")

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        #expect(manager.userPresets.count == 1)
        let saved = manager.userPresets.first
        #expect(saved?.name == "Saved Preset")
        #expect(saved?.bladeCount == 15)
        #expect(saved?.layerCount == 7)
        #expect(saved?.colorPaletteId == "neon")
        #expect(saved?.eyeCenteringEnabled == false)
    }

    @Test("saveCurrentAsPreset sets currentPresetId")
    @MainActor
    func saveSetsCurrentId() async {
        let defaults = createTestUserDefaults()
        let settings = SpiralSettings(forTesting: defaults)
        let manager = PresetManager(forTesting: defaults, settings: settings)

        manager.saveCurrentAsPreset(name: "New Preset")

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 300_000_000)

        #expect(manager.currentPresetId == manager.userPresets.first?.id)
    }

    @Test("saveCurrentAsPreset normalizes mirrorAnimationMode 0 to 1")
    @MainActor
    func saveNormalizesLegacyMode() async {
        let defaults = createTestUserDefaults()
        let settings = SpiralSettings(forTesting: defaults)
        let manager = PresetManager(forTesting: defaults, settings: settings)

        // Setting mirrorAnimationMode to 0 through property - note the property setter doesn't normalize
        // but saveCurrentAsPreset does the normalization
        settings.mirrorAnimationMode = 0

        manager.saveCurrentAsPreset(name: "Normalized Preset")

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 300_000_000)

        // The saved preset should have normalized value
        #expect(manager.userPresets.first?.mirrorAnimationMode == 1)
    }
}

// MARK: - LoadingOverlay Tests

@Suite("LoadingOverlay Tests")
struct LoadingOverlayTests {

    @Test("LoadingOverlay can be instantiated")
    @MainActor
    func instantiation() {
        let overlay = LoadingOverlay()
        #expect(overlay.body != nil)
    }

    @Test("LoadingOverlay renders without crashing")
    @MainActor
    func rendering() {
        let overlay = LoadingOverlay()
        let controller = UIHostingController(rootView: overlay)
        controller.view.frame = CGRect(x: 0, y: 0, width: 400, height: 800)
        controller.view.layoutIfNeeded()

        // Simply verify the view exists and has a non-zero size after layout
        #expect(controller.view != nil)
        #expect(controller.view.bounds.width > 0)
        #expect(controller.view.bounds.height > 0)
    }
}

// MARK: - Keyboard Shortcut Tests

@Suite("Keyboard Shortcut Tests")
struct KeyboardShortcutTests {

    @Test("KeyCommandViewController can become first responder")
    @MainActor
    func canBecomeFirstResponder() {
        let controller = KeyCommandViewController(rootView: EmptyView())
        #expect(controller.canBecomeFirstResponder == true)
    }

    @Test("KeyCommandViewController can be instantiated")
    @MainActor
    func instantiation() {
        let controller = KeyCommandViewController(rootView: EmptyView())
        #expect(controller.view != nil)
    }

    @Test("Toggle mirror changes mirrorAlwaysOn setting")
    @MainActor
    func toggleMirrorSetting() {
        let defaults = UserDefaults(suiteName: "test.keyboard.mirror.\(UUID().uuidString)")!
        let settings = SpiralSettings(forTesting: defaults)
        let originalValue = settings.mirrorAlwaysOn

        settings.mirrorAlwaysOn.toggle()

        #expect(settings.mirrorAlwaysOn == !originalValue)

        // Toggle back
        settings.mirrorAlwaysOn.toggle()
        #expect(settings.mirrorAlwaysOn == originalValue)
    }

    @Test("Capture photo notification name is correct")
    func capturePhotoNotificationName() {
        let capturePhotoName = Notification.Name("capturePhoto")
        #expect(capturePhotoName.rawValue == "capturePhoto")
    }

    @Test("Capture photo notification can be posted and received")
    @MainActor
    func capturePhotoNotificationPosting() async {
        var notificationReceived = false
        let capturePhotoName = Notification.Name("capturePhoto")

        let observer = NotificationCenter.default.addObserver(
            forName: capturePhotoName,
            object: nil,
            queue: .main
        ) { _ in
            notificationReceived = true
        }

        NotificationCenter.default.post(name: capturePhotoName, object: nil)

        // Give the notification time to propagate
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(notificationReceived == true)

        NotificationCenter.default.removeObserver(observer)
    }

    @Test("KeyCommandView can wrap content")
    @MainActor
    func keyCommandViewWrapper() {
        // Verify KeyCommandView can be created and renders
        let keyCommandView = KeyCommandView {
            Text("Test")
        }

        // Use UIHostingController to render the KeyCommandView
        let hostingController = UIHostingController(rootView: keyCommandView)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 400, height: 800)
        hostingController.view.layoutIfNeeded()

        #expect(hostingController.view != nil)
    }
}

// MARK: - AudioSessionManager Tests

@Suite("AudioSessionManager Tests")
struct AudioSessionManagerTests {

    @Test("AudioSessionManager can be created for testing")
    func creation() {
        let manager = AudioSessionManager(forTesting: true)
        #expect(manager != nil)
    }

    @Test("wasPlayingBeforePause defaults to false")
    func wasPlayingBeforePauseDefault() {
        let manager = AudioSessionManager(forTesting: true)
        #expect(manager.wasPlayingBeforePause == false)
    }

    @Test("pauseOtherAudio sets wasPlayingBeforePause when audio is playing")
    func pauseOtherAudioTracksPlayingState() {
        let manager = AudioSessionManager(forTesting: true)
        manager.simulateOtherAudioPlaying = true

        manager.pauseOtherAudio()

        #expect(manager.wasPlayingBeforePause == true)
    }

    @Test("pauseOtherAudio does not set wasPlayingBeforePause when no audio playing")
    func pauseOtherAudioNoOpWhenNotPlaying() {
        let manager = AudioSessionManager(forTesting: true)
        manager.simulateOtherAudioPlaying = false

        manager.pauseOtherAudio()

        #expect(manager.wasPlayingBeforePause == false)
    }

    @Test("resumeOtherAudio only resumes if wasPlayingBeforePause is true")
    func resumeOtherAudioOnlyIfWasPlaying() {
        let manager = AudioSessionManager(forTesting: true)
        manager.wasPlayingBeforePause = true

        manager.resumeOtherAudio()

        // After resuming, wasPlayingBeforePause should be reset
        #expect(manager.wasPlayingBeforePause == false)
    }

    @Test("resumeOtherAudio does nothing if wasPlayingBeforePause is false")
    func resumeOtherAudioNoOpIfWasNotPlaying() {
        let manager = AudioSessionManager(forTesting: true)
        manager.wasPlayingBeforePause = false

        manager.resumeOtherAudio()

        #expect(manager.wasPlayingBeforePause == false)
    }

    @Test("Full pause/resume cycle maintains correct state")
    func fullPauseResumeCycle() {
        let manager = AudioSessionManager(forTesting: true)
        manager.simulateOtherAudioPlaying = true

        // Initially not paused
        #expect(manager.wasPlayingBeforePause == false)

        // Pause - should track that audio was playing
        manager.pauseOtherAudio()
        #expect(manager.wasPlayingBeforePause == true)

        // Resume - should reset state
        manager.resumeOtherAudio()
        #expect(manager.wasPlayingBeforePause == false)
    }

    @Test("Multiple pause calls don't override wasPlayingBeforePause if already paused")
    func multiplePauseCalls() {
        let manager = AudioSessionManager(forTesting: true)
        manager.simulateOtherAudioPlaying = true

        manager.pauseOtherAudio()
        #expect(manager.wasPlayingBeforePause == true)

        // Simulate audio no longer playing (because we paused it)
        manager.simulateOtherAudioPlaying = false

        // Second pause call should not override
        manager.pauseOtherAudio()
        #expect(manager.wasPlayingBeforePause == true)
    }

    @Test("handleSpiralFrozenChange pauses audio when spiral freezes")
    func handleSpiralFrozenChangePauses() {
        let manager = AudioSessionManager(forTesting: true)
        manager.simulateOtherAudioPlaying = true

        manager.handleSpiralFrozenChange(isFrozen: true)

        #expect(manager.wasPlayingBeforePause == true)
    }

    @Test("handleSpiralFrozenChange resumes audio when spiral unfreezes")
    func handleSpiralFrozenChangeResumes() {
        let manager = AudioSessionManager(forTesting: true)
        manager.simulateOtherAudioPlaying = true

        // First freeze
        manager.handleSpiralFrozenChange(isFrozen: true)
        #expect(manager.wasPlayingBeforePause == true)

        // Then unfreeze
        manager.handleSpiralFrozenChange(isFrozen: false)
        #expect(manager.wasPlayingBeforePause == false)
    }

    @Test("handleSpiralFrozenChange does not resume if audio was not playing before pause")
    func handleSpiralFrozenChangeNoResumeIfNotPlaying() {
        let manager = AudioSessionManager(forTesting: true)
        manager.simulateOtherAudioPlaying = false

        // Freeze when no audio playing
        manager.handleSpiralFrozenChange(isFrozen: true)
        #expect(manager.wasPlayingBeforePause == false)

        // Unfreeze should not try to resume
        manager.handleSpiralFrozenChange(isFrozen: false)
        #expect(manager.wasPlayingBeforePause == false)
    }
}

// MARK: - IdleTimerManager Tests

@Suite("IdleTimerManager Tests")
@MainActor
struct IdleTimerManagerTests {

    @Test("Plugged in keeps idle timer disabled")
    func pluggedInKeepsScreenOn() {
        let manager = IdleTimerManager(forTesting: true)
        manager.handleBatteryStateChange(to: .charging)

        #expect(manager.isIdleTimerDisabledValue == true)
        #expect(manager.idleTimer == nil)
    }

    @Test("On battery starts idle timer")
    func onBatteryStartsTimer() {
        let manager = IdleTimerManager(forTesting: true)
        manager.handleBatteryStateChange(to: .unplugged)

        #expect(manager.isIdleTimerDisabledValue == true)
        #expect(manager.idleTimer != nil)
    }

    @Test("userInteracted resets timer")
    func userInteractedResetsTimer() {
        let manager = IdleTimerManager(forTesting: true, throttleInterval: 0.05)
        manager.handleBatteryStateChange(to: .unplugged)
        let firstTimer = manager.idleTimer

        // Wait past throttle
        Thread.sleep(forTimeInterval: 0.06)
        manager.userInteracted()
        let secondTimer = manager.idleTimer

        #expect(firstTimer !== secondTimer)
    }

    @Test("userInteracted is throttled within 1 second")
    func userInteractedThrottled() {
        let manager = IdleTimerManager(forTesting: true)
        manager.handleBatteryStateChange(to: .unplugged)
        let firstTimer = manager.idleTimer

        manager.userInteracted()
        let secondTimer = manager.idleTimer

        #expect(firstTimer === secondTimer)
    }

    @Test("Timer expiry allows sleep")
    func timerExpiryAllowsSleep() {
        let manager = IdleTimerManager(forTesting: true, idleTimeout: 0.5)
        manager.handleBatteryStateChange(to: .unplugged)

        #expect(manager.isIdleTimerDisabledValue == true)

        // Wait for timer to fire
        Thread.sleep(forTimeInterval: 0.8)
        RunLoop.current.run(until: Date().addingTimeInterval(0.1))

        #expect(manager.isIdleTimerDisabledValue == false)
    }

    @Test("Unknown battery state treats as unplugged and starts timer")
    func unknownBatteryStateTreatedAsUnplugged() {
        let manager = IdleTimerManager(forTesting: true)
        manager.handleBatteryStateChange(to: .unknown)

        #expect(manager.isIdleTimerDisabledValue == true)
        #expect(manager.idleTimer != nil, "Timer should be started for unknown battery state")
    }

    @Test("Plugging in after idle timer expires re-disables idle timer")
    func pluggingInAfterExpiry() {
        let manager = IdleTimerManager(forTesting: true, idleTimeout: 0.5)
        manager.handleBatteryStateChange(to: .unplugged)

        Thread.sleep(forTimeInterval: 0.8)
        RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        #expect(manager.isIdleTimerDisabledValue == false)

        manager.handleBatteryStateChange(to: .charging)
        #expect(manager.isIdleTimerDisabledValue == true)
    }
}

@Suite("IdleTrackingWindow Tests")
@MainActor
struct IdleTrackingWindowTests {

    @Test("Touch event triggers userInteracted")
    func touchEventTriggersInteraction() {
        let manager = IdleTimerManager(forTesting: true, idleTimeout: 0.5, throttleInterval: 0.05)
        manager.handleBatteryStateChange(to: .unplugged)

        // Wait for timer to fire
        Thread.sleep(forTimeInterval: 0.8)
        RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        #expect(manager.isIdleTimerDisabledValue == false)

        // Simulate what IdleTrackingWindow does
        manager.userInteracted()
        #expect(manager.isIdleTimerDisabledValue == true)
        #expect(manager.idleTimer != nil)
    }
}
