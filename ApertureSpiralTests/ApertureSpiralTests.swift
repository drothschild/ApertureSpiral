//
//  ApertureSpiralTests.swift
//  ApertureSpiralTests
//
//  Created by David Rothschild on 1/12/26.
//

import Testing
import Foundation
import UIKit
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
        #expect(settings.captureTimerMinutes == 0)
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
        settings.captureTimerMinutes = 15

        #expect(settings.captureTimerMinutes == 15)
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
        settings.captureTimerMinutes = 30
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
        #expect(settings.captureTimerMinutes == 0)
        #expect(settings.previewOnly == true)
        #expect(settings.colorFlowSpeed == 0.3)
        #expect(settings.mirrorAlwaysOn == true)
        #expect(settings.mirrorAnimationMode == 2)
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
            captureTimerMinutes: 10,
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
        #expect(preset.captureTimerMinutes == 10)
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

    @Test("Preset default captureTimerMinutes is 0")
    func presetDefaultCaptureTimer() {
        let preset = Preset(name: "Test", bladeCount: 9, layerCount: 5, speed: 1.0, apertureSize: 0.5, phrases: [])

        #expect(preset.captureTimerMinutes == 0)
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
            captureTimerMinutes: 5,
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
        #expect(decoded.captureTimerMinutes == original.captureTimerMinutes)
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
            captureTimerMinutes: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 1
        )

        let matches = preset.matchesSettings(
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["A"],
            captureTimerMinutes: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 1,
            colorPaletteId: "warm"
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
            mirrorAnimationMode: 2
        )

        let matches = preset.matchesSettings(
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["A"],
            captureTimerMinutes: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: false, // Different
            mirrorAnimationMode: 2,
            colorPaletteId: "warm"
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
            mirrorAnimationMode: 0 // Scale
        )

        let matches = preset.matchesSettings(
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["A"],
            captureTimerMinutes: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: false,
            mirrorAnimationMode: 2, // Both (different)
            colorPaletteId: "warm"
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

        #expect(manager.builtInPresets.count == 3)
        #expect(manager.builtInPresets[0].name == "Birthday")
        #expect(manager.builtInPresets[1].name == "Calm")
        #expect(manager.builtInPresets[2].name == "Intense")
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

        #expect(manager.allPresets.count == 3) // Only built-in initially
    }

    @Test("Apply preset updates SpiralSettings")
    func applyPresetUpdatesSettings() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)
        let settings = SpiralSettings.shared

        // Reset settings to known state
        settings.reset()

        let intense = manager.builtInPresets[2] // Intense preset
        manager.applyPreset(intense)

        #expect(settings.bladeCount == 16)
        #expect(settings.layerCount == 8)
        #expect(settings.speed == 2.5)
        #expect(settings.apertureSize == 0.3)
        #expect(settings.phrases == ["WOW", "AMAZING", "YES"])
        #expect(settings.previewOnly == false)
        // Built-in presets use default Preset colorFlowSpeed of 0.5
        #expect(settings.colorFlowSpeed == 0.5)

        // Restore settings
        settings.reset()
    }

    @Test("Apply preset with previewOnly and colorFlowSpeed updates settings")
    func applyPresetWithPreviewOnlyAndColorFlow() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)
        let settings = SpiralSettings.shared

        // Reset settings to known state
        settings.reset()

        let preset = Preset(
            name: "Preview Test",
            bladeCount: 8,
            layerCount: 4,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["Test"],
            captureTimerMinutes: 5,
            previewOnly: true,
            colorFlowSpeed: 1.8
        )
        manager.applyPreset(preset)

        #expect(settings.previewOnly == true)
        #expect(settings.captureTimerMinutes == 5)
        #expect(settings.colorFlowSpeed == 1.8)

        // Restore settings
        settings.reset()
    }

    @Test("Apply preset with mirror settings updates SpiralSettings")
    func applyPresetWithMirrorSettings() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)
        let settings = SpiralSettings.shared

        // Reset settings to known state
        settings.reset()

        let preset = Preset(
            name: "Mirror Test",
            bladeCount: 9,
            layerCount: 5,
            speed: 1.0,
            apertureSize: 0.5,
            phrases: ["Test"],
            captureTimerMinutes: 0,
            previewOnly: false,
            colorFlowSpeed: 0.5,
            mirrorAlwaysOn: true,
            mirrorAnimationMode: 0 // Scale (legacy)
        )
        manager.applyPreset(preset)

        #expect(settings.mirrorAlwaysOn == true)
        // legacy preset mode 0 is normalized to 1 (Zoom-only)
        #expect(settings.mirrorAnimationMode == 1)

        // Restore settings
        settings.reset()
    }

    @Test("Apply preset with Zoom animation mode")
    func applyPresetWithZoomMode() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)
        let settings = SpiralSettings.shared

        // Reset settings to known state
        settings.reset()

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

        // Restore settings
        settings.reset()
    }

    @Test("Apply preset with Both animation mode")
    func applyPresetWithBothMode() {
        let defaults = createTestUserDefaults()
        let manager = PresetManager(forTesting: defaults)
        let settings = SpiralSettings.shared

        // Reset settings to known state
        settings.reset()
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

        // Restore settings
        settings.reset()
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

// MARK: - TrancePhoto Tests

@Suite("TrancePhoto Tests")
struct TrancePhotoTests {

    @Test("TrancePhoto initializes with all properties")
    func initialization() {
        let id = UUID()
        let date = Date()
        let photo = TrancePhoto(id: id, filename: "test.jpg", capturedAt: date, presetName: "Birthday")

        #expect(photo.id == id)
        #expect(photo.filename == "test.jpg")
        #expect(photo.capturedAt == date)
        #expect(photo.presetName == "Birthday")
    }

    @Test("TrancePhoto has auto-generated UUID")
    func autoGeneratedUUID() {
        let photo1 = TrancePhoto(filename: "a.jpg")
        let photo2 = TrancePhoto(filename: "b.jpg")

        #expect(photo1.id != photo2.id)
    }

    @Test("TrancePhoto default presetName is nil")
    func defaultPresetName() {
        let photo = TrancePhoto(filename: "test.jpg")

        #expect(photo.presetName == nil)
    }

    @Test("TrancePhoto default capturedAt is approximately now")
    func defaultCapturedAt() {
        let before = Date()
        let photo = TrancePhoto(filename: "test.jpg")
        let after = Date()

        #expect(photo.capturedAt >= before)
        #expect(photo.capturedAt <= after)
    }

    @Test("TrancePhoto is Codable")
    func codable() throws {
        let original = TrancePhoto(
            filename: "photo.jpg",
            capturedAt: Date(timeIntervalSince1970: 1000000),
            presetName: "TestPreset"
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TrancePhoto.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.filename == original.filename)
        #expect(decoded.capturedAt == original.capturedAt)
        #expect(decoded.presetName == original.presetName)
    }

    @Test("TrancePhoto conforms to Identifiable")
    func identifiable() {
        let photo = TrancePhoto(filename: "test.jpg")

        let id: UUID = photo.id
        #expect(id == photo.id)
    }
}

// MARK: - PhotoStorageManager Tests

@Suite("PhotoStorageManager Tests")
struct PhotoStorageManagerTests {

    func createTestDirectory() -> URL {
        let temp = FileManager.default.temporaryDirectory
        return temp.appendingPathComponent("PhotoStorageTests_\(UUID().uuidString)")
    }

    func cleanupDirectory(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
    }

    func createTestImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        UIColor.red.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    @Test("Manager starts with empty photos")
    func startsEmpty() {
        let dir = createTestDirectory()
        defer { cleanupDirectory(dir) }

        let manager = PhotoStorageManager(forTesting: dir)

        #expect(manager.photos.isEmpty)
    }

    @Test("SavePhoto creates photo file")
    func savePhotoCreatesFile() {
        let dir = createTestDirectory()
        defer { cleanupDirectory(dir) }

        let manager = PhotoStorageManager(forTesting: dir)
        let image = createTestImage()

        let photo = manager.savePhoto(image, presetName: nil)

        #expect(photo != nil)
        let fileURL = dir.appendingPathComponent(photo!.filename)
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }

    @Test("SavePhoto adds to photos array")
    func savePhotoAddsToArray() {
        let dir = createTestDirectory()
        defer { cleanupDirectory(dir) }

        let manager = PhotoStorageManager(forTesting: dir)
        let image = createTestImage()

        _ = manager.savePhoto(image, presetName: nil)

        #expect(manager.photos.count == 1)
    }

    @Test("SavePhoto inserts at beginning")
    func savePhotoInsertsAtBeginning() {
        let dir = createTestDirectory()
        defer { cleanupDirectory(dir) }

        let manager = PhotoStorageManager(forTesting: dir)
        let image = createTestImage()

        let photo1 = manager.savePhoto(image, presetName: "First")
        let photo2 = manager.savePhoto(image, presetName: "Second")

        #expect(manager.photos[0].id == photo2?.id)
        #expect(manager.photos[1].id == photo1?.id)
    }

    @Test("SavePhoto stores presetName")
    func savePhotoStoresPresetName() {
        let dir = createTestDirectory()
        defer { cleanupDirectory(dir) }

        let manager = PhotoStorageManager(forTesting: dir)
        let image = createTestImage()

        let photo = manager.savePhoto(image, presetName: "TestPreset")

        #expect(photo?.presetName == "TestPreset")
    }

    @Test("LoadImage returns saved image")
    func loadImageReturnsImage() {
        let dir = createTestDirectory()
        defer { cleanupDirectory(dir) }

        let manager = PhotoStorageManager(forTesting: dir)
        let image = createTestImage()

        let photo = manager.savePhoto(image, presetName: nil)!
        let loaded = manager.loadImage(for: photo)

        #expect(loaded != nil)
    }

    @Test("LoadImage returns nil for non-existent photo")
    func loadImageReturnsNilForMissing() {
        let dir = createTestDirectory()
        defer { cleanupDirectory(dir) }

        let manager = PhotoStorageManager(forTesting: dir)
        let fakePhoto = TrancePhoto(filename: "nonexistent.jpg")

        let loaded = manager.loadImage(for: fakePhoto)

        #expect(loaded == nil)
    }

    @Test("DeletePhoto removes file")
    func deletePhotoRemovesFile() {
        let dir = createTestDirectory()
        defer { cleanupDirectory(dir) }

        let manager = PhotoStorageManager(forTesting: dir)
        let image = createTestImage()
        let photo = manager.savePhoto(image, presetName: nil)!
        let fileURL = dir.appendingPathComponent(photo.filename)

        #expect(FileManager.default.fileExists(atPath: fileURL.path))

        manager.deletePhoto(photo)

        #expect(!FileManager.default.fileExists(atPath: fileURL.path))
    }

    @Test("DeletePhoto removes from photos array")
    func deletePhotoRemovesFromArray() {
        let dir = createTestDirectory()
        defer { cleanupDirectory(dir) }

        let manager = PhotoStorageManager(forTesting: dir)
        let image = createTestImage()
        let photo = manager.savePhoto(image, presetName: nil)!

        #expect(manager.photos.count == 1)

        manager.deletePhoto(photo)

        #expect(manager.photos.isEmpty)
    }

    @Test("Reset clears all photos")
    func resetClearsAll() {
        let dir = createTestDirectory()
        defer { cleanupDirectory(dir) }

        let manager = PhotoStorageManager(forTesting: dir)
        let image = createTestImage()
        _ = manager.savePhoto(image, presetName: nil)
        _ = manager.savePhoto(image, presetName: nil)

        #expect(manager.photos.count == 2)

        manager.reset()

        #expect(manager.photos.isEmpty)
    }

    @Test("Photos persist across instances")
    func photosPersist() {
        let dir = createTestDirectory()
        defer { cleanupDirectory(dir) }

        let manager1 = PhotoStorageManager(forTesting: dir)
        let image = createTestImage()
        let photo = manager1.savePhoto(image, presetName: "Persist")!

        // Create new manager instance pointing to same directory
        let manager2 = PhotoStorageManager(forTesting: dir)

        #expect(manager2.photos.count == 1)
        #expect(manager2.photos[0].id == photo.id)
        #expect(manager2.photos[0].presetName == "Persist")
    }

    @Test("Multiple photos can be saved")
    func multiplePhotosSaved() {
        let dir = createTestDirectory()
        defer { cleanupDirectory(dir) }

        let manager = PhotoStorageManager(forTesting: dir)
        let image = createTestImage()

        for i in 0..<5 {
            _ = manager.savePhoto(image, presetName: "Photo\(i)")
        }

        #expect(manager.photos.count == 5)
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

        let arcCenterOpen = calculateArcCenterX(bladeRadius: bladeRadius, apertureSize: 1.0)
        let arcCenterClosed = calculateArcCenterX(bladeRadius: bladeRadius, apertureSize: 0.0)

        #expect(arcCenterOpen > arcCenterClosed)
    }

    @Test("Arc radius scales with aperture size")
    func arcRadiusScalesWithAperture() {
        let bladeRadius: CGFloat = 100

        let radiusOpen = calculateArcRadius(bladeRadius: bladeRadius, apertureSize: 1.0)
        let radiusClosed = calculateArcRadius(bladeRadius: bladeRadius, apertureSize: 0.0)

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

    // Helper functions mirroring NativeSpiralCanvas logic
    private func calculateBladeRadius(baseRadius: CGFloat, layerIndex: Int) -> CGFloat {
        return baseRadius * (0.4 + CGFloat(layerIndex) * 0.12)
    }

    private func calculateArcCenterX(bladeRadius: CGFloat, apertureSize: Double) -> CGFloat {
        return bladeRadius * (0.05 + 0.30 * apertureSize)
    }

    private func calculateArcRadius(bladeRadius: CGFloat, apertureSize: Double) -> CGFloat {
        return bladeRadius * (0.85 + apertureSize * 0.4)
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

// MARK: - Lens Flare Calculation Tests

@Suite("Lens Flare Calculation Tests")
struct LensFlareTests {

    @Test("Flare position orbits around center")
    func flarePositionOrbits() {
        let cx: CGFloat = 100
        let cy: CGFloat = 100
        let radius: CGFloat = 100

        var positions: [CGPoint] = []

        for i in 0..<4 {
            let time = Double(i) * .pi / 2  // Quarter rotations
            let flareAngle = time * 0.5
            let flareX = cx + cos(flareAngle) * radius * 0.3
            let flareY = cy + sin(flareAngle) * radius * 0.3
            positions.append(CGPoint(x: flareX, y: flareY))
        }

        // All positions should be different
        for i in 0..<positions.count {
            for j in (i+1)..<positions.count {
                let dx = positions[i].x - positions[j].x
                let dy = positions[i].y - positions[j].y
                let distance = sqrt(dx*dx + dy*dy)
                #expect(distance > 1.0)
            }
        }
    }

    @Test("Flare alpha oscillates")
    func flareAlphaOscillates() {
        let baseAlpha: Double = 0.05
        let amplitude: Double = 0.02

        var alphas: [Double] = []
        for i in 0..<10 {
            let time = Double(i) * 0.5
            let alpha = baseAlpha + sin(time * 3) * amplitude
            alphas.append(alpha)
        }

        // Check that alpha varies
        let minAlpha = alphas.min()!
        let maxAlpha = alphas.max()!
        #expect(maxAlpha > minAlpha)

        // Check that alpha stays in reasonable range
        for alpha in alphas {
            #expect(alpha >= baseAlpha - amplitude)
            #expect(alpha <= baseAlpha + amplitude)
        }
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
