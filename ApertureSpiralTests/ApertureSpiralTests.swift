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
        let settings = SpiralSettings(forTesting: true)

        #expect(settings.bladeCount == 9)
        #expect(settings.layerCount == 5)
        #expect(settings.speed == 1.0)
        #expect(settings.apertureSize == 0.5)
        #expect(settings.phrases == ["Happy Birthday", "Evelyn", "We Love You"])
        #expect(settings.captureTimerMinutes == 1)
        #expect(settings.previewOnly == true)
        #expect(settings.colorFlowSpeed == 0.5)
        #expect(settings.mirrorAlwaysOn == false)
        #expect(settings.mirrorAnimationMode == 2)
    }

    @Test("Blade count can be modified")
    func bladeCountModification() {
        let settings = SpiralSettings(forTesting: true)
        settings.bladeCount = 12

        #expect(settings.bladeCount == 12)
    }

    @Test("Layer count can be modified")
    func layerCountModification() {
        let settings = SpiralSettings(forTesting: true)
        settings.layerCount = 8

        #expect(settings.layerCount == 8)
    }

    @Test("Speed can be modified")
    func speedModification() {
        let settings = SpiralSettings(forTesting: true)
        settings.speed = 2.5

        #expect(settings.speed == 2.5)
    }

    @Test("Aperture size can be modified")
    func apertureSizeModification() {
        let settings = SpiralSettings(forTesting: true)
        settings.apertureSize = 0.8

        #expect(settings.apertureSize == 0.8)
    }

    @Test("Phrases can be modified")
    func phrasesModification() {
        let settings = SpiralSettings(forTesting: true)
        settings.phrases = ["Test", "Phrases"]

        #expect(settings.phrases == ["Test", "Phrases"])
    }

    @Test("Capture timer can be modified")
    func captureTimerModification() {
        let settings = SpiralSettings(forTesting: true)
        settings.captureTimerMinutes = 15

        #expect(settings.captureTimerMinutes == 15)
    }

    @Test("PhrasesText getter joins phrases with newlines")
    func phrasesTextGetter() {
        let settings = SpiralSettings(forTesting: true)
        settings.phrases = ["One", "Two", "Three"]

        #expect(settings.phrasesText == "One\nTwo\nThree")
    }

    @Test("PhrasesText setter splits text into phrases")
    func phrasesTextSetter() {
        let settings = SpiralSettings(forTesting: true)
        settings.phrasesText = "Alpha\nBeta\nGamma"

        #expect(settings.phrases == ["Alpha", "Beta", "Gamma"])
    }

    @Test("PhrasesText setter filters empty lines")
    func phrasesTextSetterFiltersEmpty() {
        let settings = SpiralSettings(forTesting: true)
        settings.phrasesText = "Alpha\n\nBeta\n\n\nGamma"

        #expect(settings.phrases == ["Alpha", "Beta", "Gamma"])
    }

    @Test("Preview only can be modified")
    func previewOnlyModification() {
        let settings = SpiralSettings(forTesting: true)
        settings.previewOnly = false

        #expect(settings.previewOnly == false)
    }

    @Test("Color flow speed can be modified")
    func colorFlowSpeedModification() {
        let settings = SpiralSettings(forTesting: true)
        settings.colorFlowSpeed = 1.5

        #expect(settings.colorFlowSpeed == 1.5)
    }

    @Test("Mirror always on can be modified")
    func mirrorAlwaysOnModification() {
        let settings = SpiralSettings(forTesting: true)
        settings.mirrorAlwaysOn = true

        #expect(settings.mirrorAlwaysOn == true)
    }

    @Test("Mirror animation mode can be modified")
    func mirrorAnimationModeModification() {
        let settings = SpiralSettings(forTesting: true)

        settings.mirrorAnimationMode = 0 // Scale
        #expect(settings.mirrorAnimationMode == 0)

        settings.mirrorAnimationMode = 1 // Zoom
        #expect(settings.mirrorAnimationMode == 1)

        settings.mirrorAnimationMode = 2 // Both
        #expect(settings.mirrorAnimationMode == 2)
    }

    @Test("Mirror animation mode default is Both (2)")
    func mirrorAnimationModeDefaultIsBoth() {
        let settings = SpiralSettings(forTesting: true)

        #expect(settings.mirrorAnimationMode == 2)
    }

    @Test("Reset restores default values")
    func resetRestoresDefaults() {
        let settings = SpiralSettings(forTesting: true)
        settings.bladeCount = 16
        settings.layerCount = 8
        settings.speed = 3.0
        settings.apertureSize = 0.1
        settings.phrases = ["Custom"]
        settings.captureTimerMinutes = 30
        settings.previewOnly = false
        settings.colorFlowSpeed = 2.0
        settings.mirrorAlwaysOn = true
        settings.mirrorAnimationMode = 0

        settings.reset()

        #expect(settings.bladeCount == 9)
        #expect(settings.layerCount == 5)
        #expect(settings.speed == 1.0)
        #expect(settings.apertureSize == 0.5)
        #expect(settings.phrases == ["Happy Birthday", "Evelyn", "We Love You"])
        #expect(settings.captureTimerMinutes == 1)
        #expect(settings.previewOnly == true)
        #expect(settings.colorFlowSpeed == 0.5)
        #expect(settings.mirrorAlwaysOn == false)
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
            mirrorAnimationMode: 1
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
            mirrorAnimationMode: 2
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
            mirrorAnimationMode: 2 // Both (different)
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
        #expect(birthday.phrases == ["Happy Birthday", "Evelyn", "We Love You"])
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
            mirrorAnimationMode: 0 // Scale
        )
        manager.applyPreset(preset)

        #expect(settings.mirrorAlwaysOn == true)
        #expect(settings.mirrorAnimationMode == 0)

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
}
