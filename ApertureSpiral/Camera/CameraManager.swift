import AVFoundation
import UIKit
import Combine
import Vision

class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var isSessionRunning = false
    @Published var eyeCenterOffset: CGPoint = .zero
    @Published var faceDetected: Bool = false {
        didSet { updateFreezeTimer() }
    }
    @Published var isLookingAtScreen: Bool = true {
        didSet { updateFreezeTimer() }
    }

    private let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let videoDataQueue = DispatchQueue(label: "video.data.queue", qos: .utility)

    private nonisolated(unsafe) var faceDetectionRequest: VNDetectFaceLandmarksRequest?
    private nonisolated(unsafe) var frameCounter = 0
    private var smoothedOffset: CGPoint = .zero
    private var freezeTimer: Timer?
    @Published var freezeCountdown: Int = 0
    private let settings = SpiralSettings.shared
    private var cancellables = Set<AnyCancellable>()

    // Gaze tracking state (integrated into face detection)
    private var gazeHistory: [Bool] = []
    private let gazeHistorySize = 5
    private let eyeOpenThreshold: CGFloat = 0.02

    var previewLayer: AVCaptureVideoPreviewLayer?

    override init() {
        super.init()
        checkAuthorizationStatus()
        setupFaceDetection()
        // Observe user toggling of the freeze settings so we can (re)start timer if needed
        settings.$freezeWhenNoFace
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateFreezeTimer()
            }
            .store(in: &cancellables)
        settings.$freezeWhenNotLooking
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.handleGazeTrackingSettingChanged(enabled)
            }
            .store(in: &cancellables)
    }

    private func handleGazeTrackingSettingChanged(_ enabled: Bool) {
        if !enabled {
            gazeHistory.removeAll()
            isLookingAtScreen = true  // Reset to default when disabled
        }
        updateFreezeTimer()
    }

    deinit {
        freezeTimer?.invalidate()
        freezeTimer = nil
        settings.spiralFrozen = false
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    private func setupFaceDetection() {
        // Use landmarks request which includes face bounding box AND eye data for gaze tracking
        faceDetectionRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let self = self,
                  error == nil,
                  let results = request.results as? [VNFaceObservation],
                  let face = results.first else {
                DispatchQueue.main.async {
                    self?.faceDetected = false
                    // Smoothly return to center when no face detected
                    self?.smoothedOffset = CGPoint(
                        x: (self?.smoothedOffset.x ?? 0) * 0.85,
                        y: (self?.smoothedOffset.y ?? 0) * 0.85
                    )
                    self?.eyeCenterOffset = self?.smoothedOffset ?? .zero
                    // Update gaze as not looking when no face
                    self?.updateGazeWithSmoothing(false)
                    // Ensure the freeze timer is (re)started even if faceDetected was already false
                    self?.updateFreezeTimer()
                }
                return
            }

            let offset = self.calculateFaceCenterOffset(from: face)

            // Analyze eye landmarks for gaze tracking if enabled
            var isLooking = true
            if self.settings.freezeWhenNotLooking, let landmarks = face.landmarks {
                isLooking = self.analyzeGaze(landmarks: landmarks)
            }

            DispatchQueue.main.async {
                self.faceDetected = true
                // Exponential smoothing to prevent jitter
                self.smoothedOffset = CGPoint(
                    x: self.smoothedOffset.x * 0.7 + offset.x * 0.3,
                    y: self.smoothedOffset.y * 0.7 + offset.y * 0.3
                )
                self.eyeCenterOffset = self.smoothedOffset

                // Update gaze state with smoothing
                if self.settings.freezeWhenNotLooking {
                    self.updateGazeWithSmoothing(isLooking)
                }
            }
        }
    }

    /// Analyze face landmarks to determine if user is looking at screen
    private func analyzeGaze(landmarks: VNFaceLandmarks2D) -> Bool {
        guard let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye else {
            return true  // Can't determine, assume looking
        }

        // Check if eyes are open
        let leftOpen = isEyeOpen(leftEye)
        let rightOpen = isEyeOpen(rightEye)

        // If both eyes closed, not looking
        if !leftOpen && !rightOpen {
            return false
        }

        // Check pupil positions if available
        if let leftPupil = landmarks.leftPupil,
           let rightPupil = landmarks.rightPupil {
            let leftCentered = isPupilCentered(eye: leftEye, pupil: leftPupil)
            let rightCentered = isPupilCentered(eye: rightEye, pupil: rightPupil)
            return leftCentered || rightCentered
        }

        return leftOpen || rightOpen
    }

    private func isEyeOpen(_ eye: VNFaceLandmarkRegion2D) -> Bool {
        let points = eye.normalizedPoints
        guard points.count >= 6 else { return true }

        let yValues = points.map { $0.y }
        guard let minY = yValues.min(), let maxY = yValues.max() else { return true }

        return (maxY - minY) > eyeOpenThreshold
    }

    private func isPupilCentered(eye: VNFaceLandmarkRegion2D, pupil: VNFaceLandmarkRegion2D) -> Bool {
        guard let pupilPoint = pupil.normalizedPoints.first else { return true }

        let eyePoints = eye.normalizedPoints
        guard !eyePoints.isEmpty else { return true }

        let eyeCenterX = eyePoints.map { $0.x }.reduce(0, +) / CGFloat(eyePoints.count)
        let xValues = eyePoints.map { $0.x }
        guard let minX = xValues.min(), let maxX = xValues.max() else { return true }

        let eyeWidth = maxX - minX
        guard eyeWidth > 0 else { return true }

        let offsetFromCenter = abs(pupilPoint.x - eyeCenterX) / eyeWidth
        return offsetFromCenter < 0.35
    }

    private func updateGazeWithSmoothing(_ looking: Bool) {
        gazeHistory.append(looking)
        if gazeHistory.count > gazeHistorySize {
            gazeHistory.removeFirst()
        }

        // Require majority to agree
        let lookingCount = gazeHistory.filter { $0 }.count
        isLookingAtScreen = lookingCount > gazeHistorySize / 2
    }


    /// Schedules or cancels a timer that freezes the spiral after 5s without attention.
    /// Attention is lost when: no face detected OR (gaze tracking enabled AND not looking at screen)
    private func updateFreezeTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Determine if user is paying attention
            let hasAttention = self.faceDetected && (
                !self.settings.freezeWhenNotLooking || self.isLookingAtScreen
            )

            // If user is paying attention, ensure spiral is unfrozen and cancel countdown
            if hasAttention {
                self.settings.spiralFrozen = false
                self.freezeTimer?.invalidate()
                self.freezeTimer = nil
                self.freezeCountdown = 0
                return
            }

            // Check if any freeze behavior is enabled
            let shouldFreezeOnNoFace = self.settings.freezeWhenNoFace && !self.faceDetected
            let shouldFreezeOnNotLooking = self.settings.freezeWhenNotLooking && !self.isLookingAtScreen
            guard shouldFreezeOnNoFace || shouldFreezeOnNotLooking else {
                self.freezeTimer?.invalidate()
                self.freezeTimer = nil
                self.freezeCountdown = 0
                return
            }

            // If a countdown is already running, do not restart it (prevents resetting to 5s)
            if self.freezeTimer != nil {
                return
            }

            // Start a 1s repeating timer to provide a countdown to freeze
            self.freezeCountdown = 5
            self.freezeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                if self.freezeCountdown > 0 {
                    self.freezeCountdown -= 1
                }

                if self.freezeCountdown <= 0 {
                    // Freeze spiral and stop timer
                    DispatchQueue.main.async {
                        self.settings.spiralFrozen = true
                    }
                    timer.invalidate()
                    DispatchQueue.main.async {
                        self.freezeTimer = nil
                    }
                }
            }
        }
    }
    private func calculateFaceCenterOffset(from face: VNFaceObservation) -> CGPoint {
        // Use the center of the face bounding box
        let faceCenterX = face.boundingBox.midX
        let faceCenterY = face.boundingBox.midY

        // Vision coordinates: origin at bottom-left, normalized 0-1
        // Convert to offset from center (0.5, 0.5)
        // Positive offset means face is to the right/top of center
        // For front camera (mirrored): flip X
        let offsetX = -(faceCenterX - 0.5)  // Negative because front camera is mirrored
        let offsetY = (faceCenterY - 0.5)   // Vision Y is bottom-up, but we want offset direction

        // Clamp to reasonable range (max 30% shift)
        let maxOffset: CGFloat = 0.3
        return CGPoint(
            x: max(-maxOffset, min(maxOffset, offsetX)),
            y: max(-maxOffset, min(maxOffset, offsetY))
        )
    }

    private func checkAuthorizationStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
        default:
            isAuthorized = false
        }
    }

    func requestPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            await MainActor.run { isAuthorized = true }
            return true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            await MainActor.run { isAuthorized = granted }
            return granted
        default:
            await MainActor.run { isAuthorized = false }
            return false
        }
    }

    func setupSession() {
        sessionQueue.async { [weak self] in
            self?.configureSession()
        }
    }

    private func configureSession() {
        captureSession.beginConfiguration()
        // Use medium preset for better performance on older devices (sufficient for face detection)
        captureSession.sessionPreset = .medium

        // Front camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            captureSession.commitConfiguration()
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        // Add video data output for face detection
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataQueue)
        }

        captureSession.commitConfiguration()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.previewLayer?.videoGravity = .resizeAspectFill
        }
    }

    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = true
                }
            }
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = false
                }
            }
        }
        // Ensure timer is stopped, gaze state reset, and spiral unfrozen when session stops
        DispatchQueue.main.async { [weak self] in
            self?.freezeTimer?.invalidate()
            self?.freezeTimer = nil
            self?.gazeHistory.removeAll()
            self?.isLookingAtScreen = true
            self?.settings.spiralFrozen = false
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Process every 5th frame to reduce CPU load on older devices
        frameCounter += 1
        guard frameCounter % 5 == 0 else { return }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let request = faceDetectionRequest else { return }

        // Create image request handler with correct orientation for front camera
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])

        do {
            try handler.perform([request])
        } catch {
            // Silently handle errors - face detection is optional
        }
    }
}
