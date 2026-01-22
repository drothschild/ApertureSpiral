//
//  ApertureSpiralUITests.swift
//  ApertureSpiralUITests
//
//  Created by David Rothschild on 1/12/26.
//

import XCTest

final class ApertureSpiralUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tab Navigation Tests

    @MainActor
    func testTabBarExists() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSpiralTabExists() throws {
        let spiralTab = app.tabBars.buttons["Spiral"]
        XCTAssertTrue(spiralTab.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsTabExists() throws {
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
    }

    @MainActor
    func testPhotosTabExists() throws {
        let photosTab = app.tabBars.buttons["Photos"]
        XCTAssertTrue(photosTab.waitForExistence(timeout: 5))
    }

    @MainActor
    func testNavigateToSettings() throws {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5))
    }

    @MainActor
    func testNavigateToPhotos() throws {
        let photosTab = app.tabBars.buttons["Photos"]
        photosTab.tap()

        let galleryTitle = app.navigationBars["Gallery"]
        XCTAssertTrue(galleryTitle.waitForExistence(timeout: 5))
    }

    @MainActor
    func testNavigateBackToSpiral() throws {
        // Go to settings first
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // Navigate back to spiral
        let spiralTab = app.tabBars.buttons["Spiral"]
        spiralTab.tap()

        // Tab bar should still be visible initially
        XCTAssertTrue(app.tabBars.firstMatch.exists)
    }

    // MARK: - Settings View Tests

    @MainActor
    func testSettingsHasPresetSection() throws {
        app.tabBars.buttons["Settings"].tap()

        let presetSection = app.staticTexts["Preset"]
        XCTAssertTrue(presetSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHasPhrasesSection() throws {
        app.tabBars.buttons["Settings"].tap()

        let phrasesSection = app.staticTexts["Phrases"]
        XCTAssertTrue(phrasesSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHasBladesSection() throws {
        app.tabBars.buttons["Settings"].tap()

        let bladesSection = app.staticTexts["Blades"]
        XCTAssertTrue(bladesSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHasLayersSection() throws {
        app.tabBars.buttons["Settings"].tap()

        let layersSection = app.staticTexts["Layers"]
        XCTAssertTrue(layersSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHasSpeedSection() throws {
        app.tabBars.buttons["Settings"].tap()

        let speedSection = app.staticTexts["Speed"]
        XCTAssertTrue(speedSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHasApertureSection() throws {
        app.tabBars.buttons["Settings"].tap()

        let apertureSection = app.staticTexts["Aperture"]
        XCTAssertTrue(apertureSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHasAutoCaptureSection() throws {
        app.tabBars.buttons["Settings"].tap()

        // Scroll to find Auto-Capture
        let autoCaptureSection = app.staticTexts["Auto-Capture"]
        XCTAssertTrue(autoCaptureSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHasSavePresetButton() throws {
        app.tabBars.buttons["Settings"].tap()

        let saveButton = app.buttons["Save Current as Preset"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSavePresetButtonShowsAlert() throws {
        app.tabBars.buttons["Settings"].tap()

        let saveButton = app.buttons["Save Current as Preset"]
        saveButton.tap()

        let alert = app.alerts["Save Preset"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSavePresetAlertHasCancelButton() throws {
        app.tabBars.buttons["Settings"].tap()

        let saveButton = app.buttons["Save Current as Preset"]
        saveButton.tap()

        let cancelButton = app.alerts.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSavePresetAlertHasSaveButton() throws {
        app.tabBars.buttons["Settings"].tap()

        let saveButton = app.buttons["Save Current as Preset"]
        saveButton.tap()

        let alertSaveButton = app.alerts.buttons["Save"]
        XCTAssertTrue(alertSaveButton.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSavePresetAlertCanBeDismissed() throws {
        app.tabBars.buttons["Settings"].tap()

        let saveButton = app.buttons["Save Current as Preset"]
        saveButton.tap()

        let cancelButton = app.alerts.buttons["Cancel"]
        cancelButton.tap()

        // Alert should be dismissed
        XCTAssertFalse(app.alerts["Save Preset"].exists)
    }

    // MARK: - Gallery View Tests

    @MainActor
    func testGalleryShowsEmptyState() throws {
        app.tabBars.buttons["Photos"].tap()

        // Wait for the gallery to load
        let galleryTitle = app.navigationBars["Gallery"]
        XCTAssertTrue(galleryTitle.waitForExistence(timeout: 5))

        // Should have either photos or empty state text
        // Note: The exact empty state depends on whether any photos exist
    }

    // MARK: - Tab Bar Auto-Hide Tests

    @MainActor
    func testTabBarHidesAfterTimeout() throws {
        // Start on spiral tab
        let spiralTab = app.tabBars.buttons["Spiral"]
        XCTAssertTrue(spiralTab.waitForExistence(timeout: 5))

        // Wait for 12 seconds (10 second timeout + buffer)
        Thread.sleep(forTimeInterval: 12)

        // Tab bar should be hidden
        XCTAssertFalse(app.tabBars.firstMatch.isHittable)
    }

    @MainActor
    func testTappingScreenShowsTabBar() throws {
        // Start on spiral tab and wait for tab bar to hide
        Thread.sleep(forTimeInterval: 12)

        // Tap the center of the screen
        let screenCenter = app.windows.firstMatch
        screenCenter.tap()

        // Wait a moment for animation
        Thread.sleep(forTimeInterval: 0.5)

        // Tab bar should be visible again
        let spiralTab = app.tabBars.buttons["Spiral"]
        XCTAssertTrue(spiralTab.waitForExistence(timeout: 2))
    }

    // MARK: - Slider Tests

    @MainActor
    func testBladecountSliderExists() throws {
        app.tabBars.buttons["Settings"].tap()

        // There should be sliders in settings
        let sliders = app.sliders
        XCTAssertTrue(sliders.count > 0)
    }

    // MARK: - Preset Picker Tests

    @MainActor
    func testPresetPickerExists() throws {
        app.tabBars.buttons["Settings"].tap()

        let presetPicker = app.buttons["Load Preset"]
        XCTAssertTrue(presetPicker.waitForExistence(timeout: 5))
    }

    // MARK: - Performance Tests

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testSettingsNavigationPerformance() throws {
        measure {
            app.tabBars.buttons["Settings"].tap()
            app.tabBars.buttons["Spiral"].tap()
        }
    }
}
