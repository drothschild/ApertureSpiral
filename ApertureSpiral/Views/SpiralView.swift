import SwiftUI
import Combine

struct SpiralView: View {
    @Binding var selectedTab: Int
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var settings = SpiralSettings.shared
    @State private var showCameraPreview = false
    @State private var hideTabBar = false
    @State private var hideTask: Task<Void, Never>?
    @State private var dragStartLocation: CGFloat = 0
    @State private var showSpeedIndicator = false
    @State private var holeDiameter: CGFloat = 100
    @State private var maxHoleDiameter: CGFloat = 150
    @State private var currentPhraseIndex: Int = -1
    @State private var showPhrase: Bool = false
    @State private var isLoading = true
    @State private var loadingId = UUID()
    @State private var phraseTimerSubscription: AnyCancellable?

    private var cameraVisible: Bool {
        showCameraPreview || settings.mirrorAlwaysOn
    }

    var body: some View {
        ZStack {
            // Native spiral canvas
            NativeSpiralCanvas(
                settings: settings,
                holeDiameter: $holeDiameter,
                maxHoleDiameter: $maxHoleDiameter
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
                        default: // Clip mode (0): fixed size, clipped to shrinking circle (like photo)
                            CameraPreviewView(
                                previewLayer: cameraManager.previewLayer,
                                eyeCenterOffset: cameraManager.eyeCenterOffset,
                                eyeCenteringEnabled: settings.eyeCenteringEnabled
                            )
                                .frame(width: fixedCameraSize, height: fixedCameraSize)
                                .mask(
                                    Circle()
                                        .frame(width: holeDiameter, height: holeDiameter)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(cameraManager.faceDetected ? Color.blue.opacity(0.8) : Color.yellow.opacity(0.8), lineWidth: 3)
                                        .frame(width: holeDiameter, height: holeDiameter)
                                )
                                .shadow(color: .black.opacity(0.7), radius: 10)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                .ignoresSafeArea()
            }

            // Phrase overlay - shows phrases or frozen message
            if showPhrase || settings.spiralFrozen {
                let displayText: String =
                    settings.spiralFrozen
                    ? "LOOK AT THE SPIRAL"
                    : (!settings.phrases.isEmpty && currentPhraseIndex >= 0 && currentPhraseIndex < settings.phrases.count
                       ? settings.phrases[currentPhraseIndex].trimmingCharacters(in: .whitespaces)
                       : "")

                if !displayText.isEmpty {
                    Text(displayText)
                        .font(.custom("Bebas Neue", size: settings.spiralFrozen ? 72 : 48))
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                        .foregroundColor(settings.spiralFrozen ? .yellow : .white)
                        .shadow(color: .black, radius: settings.spiralFrozen ? 8 : 4, x: 0, y: 2)
                        .shadow(color: .black.opacity(0.7), radius: settings.spiralFrozen ? 16 : 8, x: 0, y: 4)
                        .shadow(color: settings.spiralFrozen ? .yellow.opacity(0.5) : .clear, radius: 20)
                        .transition(.opacity)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .animation(.easeInOut(duration: 0.3), value: settings.spiralFrozen)
                        .ignoresSafeArea()
                }
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

            // Loading overlay
            if isLoading {
                LoadingOverlay()
                    .id(loadingId)
                    .transition(.opacity)
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
            showLoadingScreen()
            setupPhraseTimer()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            hideTask?.cancel()
            hideTabBar = false
            phraseTimerSubscription?.cancel()
        }
        .onReceive(settings.$phraseDisplayDuration) { _ in
            setupPhraseTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showSpeedIndicator)) { _ in
            showSpeedIndicatorBriefly()
        }
        .animation(.easeInOut(duration: 0.3), value: showCameraPreview)
        .animation(.easeInOut(duration: 0.3), value: hideTabBar)
        .animation(.easeInOut(duration: 0.2), value: showSpeedIndicator)
        .animation(.easeInOut(duration: 0.3), value: showPhrase)
        .onChange(of: selectedTab) { _, newTab in
            if newTab == 0 {
                // Switched to spiral tab - show loading screen
                showLoadingScreen()
            }
        }
    }

    private func setupPhraseTimer() {
        phraseTimerSubscription?.cancel()
        phraseTimerSubscription = Timer.publish(every: settings.phraseDisplayDuration, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                cyclePhrase()
            }
    }

    private func showLoadingScreen() {
        loadingId = UUID()  // Force LoadingOverlay to recreate and restart animations
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                isLoading = false
            }
        }
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
        // Don't cycle phrases when spiral is frozen - only show "LOOK AT THE SPIRAL"
        guard !settings.spiralFrozen, !settings.phrases.isEmpty else {
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

}

#Preview {
    SpiralView(selectedTab: .constant(0))
}
