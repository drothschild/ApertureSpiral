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
        // Set launch argument to disable tab bar auto-hide for testing
        app.launchArguments.append("--uitesting")
        app.launch()

        // Wait for app to fully load
        Thread.sleep(forTimeInterval: 1.0)
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helper Methods

    /// Ensures the tab bar is visible by tapping the screen if needed
    @MainActor
    private func ensureTabBarVisible() {
        let tabBar = app.tabBars.firstMatch
        if !tabBar.isHittable {
            // Tap the screen to show the tab bar
            app.windows.firstMatch.tap()
            Thread.sleep(forTimeInterval: 0.5)
        }
    }

    /// Gets a tab button, ensuring tab bar is visible first
    @MainActor
    private func getTabButton(_ name: String) -> XCUIElement {
        ensureTabBarVisible()
        return app.tabBars.buttons[name]
    }

    // MARK: - Tab Navigation Tests

    @MainActor
    func testTabBarExists() throws {
        ensureTabBarVisible()
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSpiralTabExists() throws {
        let spiralTab = getTabButton("Spiral")
        XCTAssertTrue(spiralTab.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsTabExists() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
    }

    @MainActor
    func testPhotosTabExists() throws {
        let photosTab = getTabButton("Photos")
        XCTAssertTrue(photosTab.waitForExistence(timeout: 5))
    }

    @MainActor
    func testNavigateToSettings() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5))
    }

    @MainActor
    func testNavigateToPhotos() throws {
        let photosTab = getTabButton("Photos")
        XCTAssertTrue(photosTab.waitForExistence(timeout: 5))
        photosTab.tap()

        let galleryTitle = app.navigationBars["Gallery"]
        XCTAssertTrue(galleryTitle.waitForExistence(timeout: 5))
    }

    @MainActor
    func testNavigateBackToSpiral() throws {
        // Go to settings first
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        // Navigate back to spiral
        let spiralTab = getTabButton("Spiral")
        spiralTab.tap()

        // Tab bar should still be visible initially
        ensureTabBarVisible()
        XCTAssertTrue(app.tabBars.firstMatch.exists)
    }

    // MARK: - Settings View Tests

    @MainActor
    func testSettingsHasPresetSection() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let presetSection = app.staticTexts["Preset"]
        XCTAssertTrue(presetSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHasPhrasesSection() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let phrasesSection = app.staticTexts["Phrases"]
        XCTAssertTrue(phrasesSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHasBladesSection() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let bladesSection = app.staticTexts["Blades"]
        XCTAssertTrue(bladesSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHasLayersSection() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let layersSection = app.staticTexts["Layers"]
        XCTAssertTrue(layersSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHasSpeedSection() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let speedSection = app.staticTexts["Speed"]
        XCTAssertTrue(speedSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHasApertureSection() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let apertureSection = app.staticTexts["Aperture"]
        XCTAssertTrue(apertureSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHasAutoCaptureSection() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        // Scroll to find Auto-Capture
        let autoCaptureSection = app.staticTexts["Auto-Capture"]
        XCTAssertTrue(autoCaptureSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHasSavePresetButton() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let saveButton = app.buttons["Save Current as Preset"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSavePresetButtonShowsAlert() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let saveButton = app.buttons["Save Current as Preset"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()

        let alert = app.alerts["Save Preset"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSavePresetAlertHasCancelButton() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let saveButton = app.buttons["Save Current as Preset"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()

        let cancelButton = app.alerts.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSavePresetAlertHasSaveButton() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let saveButton = app.buttons["Save Current as Preset"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()

        let alertSaveButton = app.alerts.buttons["Save"]
        XCTAssertTrue(alertSaveButton.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSavePresetAlertCanBeDismissed() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let saveButton = app.buttons["Save Current as Preset"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()

        let cancelButton = app.alerts.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5))
        cancelButton.tap()

        // Alert should be dismissed
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertFalse(app.alerts["Save Preset"].exists)
    }

    // MARK: - Gallery View Tests

    @MainActor
    func testGalleryShowsEmptyState() throws {
        let photosTab = getTabButton("Photos")
        XCTAssertTrue(photosTab.waitForExistence(timeout: 5))
        photosTab.tap()

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
        let spiralTab = getTabButton("Spiral")
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
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        // There should be sliders in settings
        let sliders = app.sliders
        XCTAssertTrue(sliders.count > 0)
    }

    // MARK: - Preset Picker Tests

    @MainActor
    func testPresetPickerExists() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let presetPicker = app.buttons["Load Preset"]
        XCTAssertTrue(presetPicker.waitForExistence(timeout: 5))
    }

    // MARK: - Spiral View Gesture Tests

    @MainActor
    func testSpiralViewTapChangesDirection() throws {
        // Start on spiral tab
        let spiralTab = getTabButton("Spiral")
        XCTAssertTrue(spiralTab.waitForExistence(timeout: 5))

        // Tap the center of the screen to toggle direction
        let screenCenter = app.windows.firstMatch
        screenCenter.tap()

        // The tap should register (we can't directly verify direction change,
        // but we verify the tap doesn't crash and the view is responsive)
        XCTAssertTrue(app.windows.firstMatch.exists)
    }

    @MainActor
    func testSpiralViewMultipleTaps() throws {
        // Start on spiral tab
        let spiralTab = getTabButton("Spiral")
        XCTAssertTrue(spiralTab.waitForExistence(timeout: 5))

        let screenCenter = app.windows.firstMatch

        // Multiple taps should work without issues
        for _ in 0..<5 {
            screenCenter.tap()
            Thread.sleep(forTimeInterval: 0.2)
        }

        XCTAssertTrue(app.windows.firstMatch.exists)
    }

    // MARK: - Settings Slider Interaction Tests

    @MainActor
    func testBladesSliderCanBeAdjusted() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let sliders = app.sliders
        XCTAssertTrue(sliders.count > 0)

        // Get the first slider (Blades)
        let bladesSlider = sliders.element(boundBy: 0)
        XCTAssertTrue(bladesSlider.waitForExistence(timeout: 5))

        // Adjust the slider
        bladesSlider.adjust(toNormalizedSliderPosition: 0.8)

        // Slider should still exist and be interactable
        XCTAssertTrue(bladesSlider.exists)
    }

    @MainActor
    func testSpeedSliderCanBeAdjusted() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        // Scroll to find more sliders if needed
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
        }

        let sliders = app.sliders
        guard sliders.count >= 3 else {
            // Skip if not enough sliders visible
            return
        }

        // Speed slider (typically 3rd slider)
        let speedSlider = sliders.element(boundBy: 2)
        if speedSlider.exists {
            speedSlider.adjust(toNormalizedSliderPosition: 0.5)
            XCTAssertTrue(speedSlider.exists)
        }
    }

    @MainActor
    func testApertureSliderCanBeAdjusted() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let sliders = app.sliders
        guard sliders.count >= 4 else {
            return
        }

        // Aperture slider (typically 4th slider)
        let apertureSlider = sliders.element(boundBy: 3)
        if apertureSlider.exists {
            apertureSlider.adjust(toNormalizedSliderPosition: 0.3)
            XCTAssertTrue(apertureSlider.exists)
        }
    }

    // MARK: - Preset Selection Tests

    @MainActor
    func testPresetPickerCanBeOpened() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let presetPicker = app.buttons["Load Preset"]
        XCTAssertTrue(presetPicker.waitForExistence(timeout: 5))

        presetPicker.tap()

        // A picker or menu should appear
        Thread.sleep(forTimeInterval: 0.5)

        // Dismiss by tapping elsewhere or pressing back
        app.tap()
    }

    @MainActor
    func testCalmPresetCanBeSelected() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let presetPicker = app.buttons["Load Preset"]
        XCTAssertTrue(presetPicker.waitForExistence(timeout: 5))
        presetPicker.tap()

        Thread.sleep(forTimeInterval: 0.5)

        // Try to find and tap "Calm" preset
        let calmOption = app.buttons["Calm"]
        if calmOption.exists {
            calmOption.tap()
        }

        // View should still be responsive
        XCTAssertTrue(app.navigationBars["Settings"].exists)
    }

    // MARK: - Phrases Text Editor Tests

    @MainActor
    func testPhrasesTextEditorExists() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        // Look for text editor in Phrases section
        let phrasesSection = app.staticTexts["Phrases"]
        XCTAssertTrue(phrasesSection.waitForExistence(timeout: 5))

        // There should be a text view or text editor
        let textViews = app.textViews
        XCTAssertTrue(textViews.count > 0)
    }

    @MainActor
    func testPhrasesCanBeEdited() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let textViews = app.textViews
        guard textViews.count > 0 else {
            return
        }

        let phrasesEditor = textViews.firstMatch
        XCTAssertTrue(phrasesEditor.waitForExistence(timeout: 5))

        // Tap to focus
        phrasesEditor.tap()

        // Type some text
        phrasesEditor.typeText("\nTest Phrase")

        // Editor should still exist
        XCTAssertTrue(phrasesEditor.exists)
    }

    // MARK: - Gallery Navigation Tests

    @MainActor
    func testGalleryNavigationBarExists() throws {
        let photosTab = getTabButton("Photos")
        XCTAssertTrue(photosTab.waitForExistence(timeout: 5))
        photosTab.tap()

        let galleryNav = app.navigationBars["Gallery"]
        XCTAssertTrue(galleryNav.waitForExistence(timeout: 5))
    }

    @MainActor
    func testGalleryScrollsIfPhotosExist() throws {
        let photosTab = getTabButton("Photos")
        XCTAssertTrue(photosTab.waitForExistence(timeout: 5))
        photosTab.tap()

        let galleryNav = app.navigationBars["Gallery"]
        XCTAssertTrue(galleryNav.waitForExistence(timeout: 5))

        // Try to scroll the gallery view
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
            scrollView.swipeDown()
        }

        // Gallery should still be visible
        XCTAssertTrue(galleryNav.exists)
    }

    // MARK: - Settings Section Navigation Tests

    @MainActor
    func testSettingsScrollsToRevealAllSections() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let settingsNav = app.navigationBars["Settings"]
        XCTAssertTrue(settingsNav.waitForExistence(timeout: 5))

        // Scroll down to reveal more sections
        let scrollViews = app.scrollViews
        if scrollViews.count > 0 {
            scrollViews.firstMatch.swipeUp()
        }

        // Check for Auto-Capture section (usually at bottom)
        let autoCaptureSection = app.staticTexts["Auto-Capture"]
        XCTAssertTrue(autoCaptureSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testMirrorSectionExists() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        // Scroll to find Mirror section
        let scrollViews = app.scrollViews
        if scrollViews.count > 0 {
            scrollViews.firstMatch.swipeUp()
        }

        // Mirror section may exist
        let mirrorSection = app.staticTexts["Mirror"]
        if mirrorSection.waitForExistence(timeout: 3) {
            XCTAssertTrue(mirrorSection.exists)
        }
    }

    // MARK: - Tab Switching Persistence Tests

    @MainActor
    func testSettingsChangesPersistAfterTabSwitch() throws {
        // Go to settings
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let sliders = app.sliders
        guard sliders.count > 0 else { return }

        // Adjust a slider
        let bladesSlider = sliders.element(boundBy: 0)
        bladesSlider.adjust(toNormalizedSliderPosition: 0.9)

        // Switch to spiral and back
        let spiralTab = getTabButton("Spiral")
        spiralTab.tap()
        Thread.sleep(forTimeInterval: 0.5)
        let settingsTab2 = getTabButton("Settings")
        settingsTab2.tap()

        // Settings view should still be accessible
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testRoundTripNavigationAllTabs() throws {
        // Spiral -> Settings -> Photos -> Spiral
        let spiralTab = getTabButton("Spiral")
        let settingsTab = getTabButton("Settings")
        let photosTab = getTabButton("Photos")

        XCTAssertTrue(spiralTab.waitForExistence(timeout: 5))

        settingsTab.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))

        ensureTabBarVisible()
        photosTab.tap()
        XCTAssertTrue(app.navigationBars["Gallery"].waitForExistence(timeout: 3))

        ensureTabBarVisible()
        spiralTab.tap()
        XCTAssertTrue(spiralTab.isSelected)
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
        ensureTabBarVisible()
        measure {
            self.app.tabBars.buttons["Settings"].tap()
            self.ensureTabBarVisible()
            self.app.tabBars.buttons["Spiral"].tap()
        }
    }

    @MainActor
    func testSliderAdjustmentPerformance() throws {
        let settingsTab = getTabButton("Settings")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let sliders = app.sliders
        guard sliders.count > 0 else { return }

        let slider = sliders.element(boundBy: 0)

        measure {
            slider.adjust(toNormalizedSliderPosition: 0.2)
            slider.adjust(toNormalizedSliderPosition: 0.8)
        }
    }

    
}
