import SwiftUI
import Combine

struct SpiralView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var storageManager = PhotoStorageManager.shared
    @StateObject private var settings = SpiralSettings.shared
    @State private var timerEndDate: Date?
    @State private var showCaptureFlash = false
    @State private var showCameraPreview = false
    @State private var hideTabBar = false
    @State private var hideTask: Task<Void, Never>?
    @State private var dragStartLocation: CGFloat = 0
    @State private var showSpeedIndicator = false
    @State private var holeDiameter: CGFloat = 100
    @State private var maxHoleDiameter: CGFloat = 150
    @State private var currentPhraseIndex: Int = -1
    @State private var showPhrase: Bool = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let phraseTimer = Timer.publish(every: 0.75, on: .main, in: .common).autoconnect()

    private var cameraVisible: Bool {
        showCameraPreview || settings.mirrorAlwaysOn
    }

    var body: some View {
        ZStack {
            // Native spiral canvas
            NativeSpiralCanvas(
                settings: settings,
                holeDiameter: $holeDiameter,
                maxHoleDiameter: $maxHoleDiameter,
                hideWords: cameraVisible
            )

            // Camera preview overlay (center) - shown during capture or when always on
            // 0 = Scale: frame changes size
            // 1 = Zoom: frame fixed, content zooms
            // 2 = Both: frame changes size AND content zooms
            if cameraVisible && cameraManager.isAuthorized {
                GeometryReader { geometry in
                    // Zoom multiplier: 1.0 at max hole, increases as hole shrinks
                    let zoomMultiplier = maxHoleDiameter > 0 ? maxHoleDiameter / max(holeDiameter, 1) : 1.0
                    // Fixed camera view size - never changes, prevents layout thrashing
                    let fixedCameraSize = maxHoleDiameter

                    Group {
                        switch settings.mirrorAnimationMode {
                        case 1: // Zoom mode: fixed frame size, content zooms in/out
                            CameraPreviewView(
                                previewLayer: cameraManager.previewLayer,
                                eyeCenterOffset: cameraManager.eyeCenterOffset,
                                eyeCenteringEnabled: settings.eyeCenteringEnabled
                            )
                                .frame(width: fixedCameraSize, height: fixedCameraSize)
                                .scaleEffect(zoomMultiplier)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(cameraManager.faceDetected ? Color.blue.opacity(0.8) : Color.yellow.opacity(0.8), lineWidth: 3))
                                .shadow(color: .black.opacity(0.7), radius: 10)
                                .transition(.scale.combined(with: .opacity))
                        case 2: // Both mode: frame scales AND content zooms
                            CameraPreviewView(
                                previewLayer: cameraManager.previewLayer,
                                eyeCenterOffset: cameraManager.eyeCenterOffset,
                                eyeCenteringEnabled: settings.eyeCenteringEnabled
                            )
                                .frame(width: fixedCameraSize, height: fixedCameraSize)
                                .scaleEffect(zoomMultiplier)
                                .frame(width: holeDiameter, height: holeDiameter)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(cameraManager.faceDetected ? Color.blue.opacity(0.8) : Color.yellow.opacity(0.8), lineWidth: 3))
                                .shadow(color: .black.opacity(0.7), radius: 10)
                                .transition(.scale.combined(with: .opacity))
                        default: // Scale mode (0): frame changes size only
                            CameraPreviewView(
                                previewLayer: cameraManager.previewLayer,
                                eyeCenterOffset: cameraManager.eyeCenterOffset,
                                eyeCenteringEnabled: settings.eyeCenteringEnabled
                            )
                                .frame(width: holeDiameter, height: holeDiameter)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(cameraManager.faceDetected ? Color.blue.opacity(0.8) : Color.yellow.opacity(0.8), lineWidth: 3))
                                .shadow(color: .black.opacity(0.7), radius: 10)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                .ignoresSafeArea()
            }

            // Phrase overlay on camera preview
            if cameraVisible && showPhrase {
                GeometryReader { geometry in
                    let displayText: String =
                        settings.spiralFrozen
                        ? "LOOK AT THE SPIRAL"
                        : (!settings.phrases.isEmpty && currentPhraseIndex >= 0 && currentPhraseIndex < settings.phrases.count
                           ? settings.phrases[currentPhraseIndex].trimmingCharacters(in: .whitespaces).uppercased()
                           : "")

                    if !displayText.isEmpty {
                        Text(displayText)
                            .font(.custom("Bebas Neue", size: 48))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 4, x: 0, y: 2)
                            .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                            .transition(.opacity)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                }
                .ignoresSafeArea()
            }

            // Capture flash effect
            if showCaptureFlash {
                Color.white
                    .ignoresSafeArea()
                    .opacity(0.8)
            }

            // Speed indicator overlay
            if showSpeedIndicator {
                VStack {
                    Spacer()
                    Text(String(format: "%.1fx", settings.speed))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.6))
                        )
                        .transition(.opacity)
                    Spacer()
                }
            }

            // Tap overlay to show tab bar (only when hidden)
            if hideTabBar {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        showTabBarTemporarily()
                    }
            }
        }
        .highPriorityGesture(
            DragGesture(minimumDistance: 30)
                .onChanged { value in
                    if dragStartLocation == 0 {
                        dragStartLocation = value.startLocation.x
                    }
                }
                .onEnded { value in
                    let horizontalDistance = value.location.x - dragStartLocation
                    let verticalDistance = abs(value.location.y - value.startLocation.y)

                    // Only process if horizontal swipe is dominant
                    if abs(horizontalDistance) > verticalDistance {
                        let speedChange = 0.4
                        if horizontalDistance > 50 {
                            // Swipe right (forward) - faster
                            settings.speed = min(3.0, settings.speed + speedChange)
                            showSpeedIndicatorBriefly()
                        } else if horizontalDistance < -50 {
                            // Swipe left (back) - slower
                            settings.speed = max(0.1, settings.speed - speedChange)
                            showSpeedIndicatorBriefly()
                        }
                    }
                    dragStartLocation = 0
                }
        )
        .toolbar(hideTabBar ? .hidden : .visible, for: .tabBar)
        .statusBarHidden(true)
        .task {
            let authorized = await cameraManager.requestPermission()
            if authorized {
                cameraManager.setupSession()
                try? await Task.sleep(nanoseconds: 500_000_000)
                cameraManager.startSession()
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            scheduleHideTabBar()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            hideTask?.cancel()
            hideTabBar = false
        }
        .onReceive(timer) { _ in
            checkCaptureTimer()
        }
        .onReceive(settings.$captureTimerMinutes) { minutes in
            updateCaptureTimer(minutes: minutes)
        }
        .onReceive(phraseTimer) { _ in
            cyclePhrase()
        }
        .animation(.easeOut(duration: 0.3), value: showCaptureFlash)
        .animation(.easeInOut(duration: 0.3), value: showCameraPreview)
        .animation(.easeInOut(duration: 0.3), value: hideTabBar)
        .animation(.easeInOut(duration: 0.2), value: showSpeedIndicator)
        .animation(.easeInOut(duration: 0.3), value: showPhrase)
    }

    private func scheduleHideTabBar() {
        hideTask?.cancel()
        hideTask = Task {
            try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
            if !Task.isCancelled {
                await MainActor.run {
                    hideTabBar = true
                }
            }
        }
    }

    private func showTabBarTemporarily() {
        hideTabBar = false
        scheduleHideTabBar()
    }

    private func showSpeedIndicatorBriefly() {
        showSpeedIndicator = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showSpeedIndicator = false
        }
    }

    private func cyclePhrase() {
        guard cameraVisible && !settings.phrases.isEmpty else {
            showPhrase = false
            return
        }

        if showPhrase {
            // Hide phrase, prepare for next
            showPhrase = false
        } else {
            // Show next phrase
            if settings.phrases.count > 1 {
                var newIndex: Int
                repeat {
                    newIndex = Int.random(in: 0..<settings.phrases.count)
                } while newIndex == currentPhraseIndex
                currentPhraseIndex = newIndex
            } else {
                currentPhraseIndex = 0
            }
            showPhrase = true
        }
    }

    private func updateCaptureTimer(minutes: Int) {
        if minutes > 0 {
            timerEndDate = Date().addingTimeInterval(TimeInterval(minutes * 60))
        } else {
            timerEndDate = nil
        }
    }

    private func checkCaptureTimer() {
        guard let endDate = timerEndDate, Date() >= endDate else { return }
        capturePhoto()
        // Reset timer for another capture at the same interval
        if settings.captureTimerMinutes > 0 {
            timerEndDate = Date().addingTimeInterval(TimeInterval(settings.captureTimerMinutes * 60))
        } else {
            timerEndDate = nil
        }
    }

    private func capturePhoto() {
        showCameraPreview = true

        // If preview only mode, just show the preview for a while then hide it
        if settings.previewOnly {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                showCameraPreview = false
            }
            return
        }

        // Normal capture mode
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCaptureFlash = true

            cameraManager.capturePhoto { image in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showCaptureFlash = false
                    showCameraPreview = false
                }

                if let image = image {
                    _ = storageManager.savePhoto(image, presetName: nil)
                }
            }
        }
    }
}

#Preview {
    SpiralView()
}
