import Foundation
import ARKit
import Vision
import AVFoundation

// MARK: - GazeTracker Protocol

protocol GazeTracker: AnyObject {
    var isLookingAtScreen: Bool { get }
    var onGazeUpdate: ((Bool) -> Void)? { get set }
    func start()
    func stop()
}

// MARK: - Factory

enum GazeTrackerFactory {
    /// Creates a gaze tracker that works with the existing AVCaptureSession video pipeline.
    /// Always uses Vision-based tracking to avoid conflicts with AVCaptureSession.
    /// (ARKit face tracking requires exclusive TrueDepth camera access)
    static func create() -> GazeTracker {
        return VisionGazeTracker()
    }

    /// Whether ARKit face tracking is supported (informational only - not used due to AVCapture conflict)
    static var isARKitSupported: Bool {
        ARFaceTrackingConfiguration.isSupported
    }
}

// MARK: - ARKit Implementation (Face ID devices)

class ARKitGazeTracker: NSObject, GazeTracker, ARSessionDelegate {
    private(set) var isLookingAtScreen: Bool = true {
        didSet {
            if oldValue != isLookingAtScreen {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.onGazeUpdate?(self.isLookingAtScreen)
                }
            }
        }
    }
    var onGazeUpdate: ((Bool) -> Void)?

    private var arSession: ARSession?
    private let gazeAngleThreshold: Float = 25 * .pi / 180  // 25 degrees

    // Smoothing to prevent jitter
    private var lookingHistory: [Bool] = []
    private let historySize = 5

    func start() {
        guard ARFaceTrackingConfiguration.isSupported else { return }

        let session = ARSession()
        session.delegate = self

        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = false  // We don't need lighting

        session.run(configuration, options: [.resetTracking])
        arSession = session
    }

    func stop() {
        arSession?.pause()
        arSession = nil
        lookingHistory.removeAll()
        isLookingAtScreen = true
    }

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else {
            updateWithSmoothing(false)
            return
        }

        // lookAtPoint is in face coordinate space
        // When looking straight at camera: small X/Y, positive Z
        let lookAt = faceAnchor.lookAtPoint

        // Calculate angle from straight ahead (Z axis)
        let horizontalOffset = sqrt(lookAt.x * lookAt.x + lookAt.y * lookAt.y)
        let gazeAngle = atan2(horizontalOffset, abs(lookAt.z))

        // User is looking at screen if gaze is within threshold of straight ahead
        let looking = gazeAngle < gazeAngleThreshold
        updateWithSmoothing(looking)
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // On failure, assume looking to avoid false freezes
        isLookingAtScreen = true
    }

    private func updateWithSmoothing(_ looking: Bool) {
        lookingHistory.append(looking)
        if lookingHistory.count > historySize {
            lookingHistory.removeFirst()
        }

        // Require majority of recent frames to agree
        let lookingCount = lookingHistory.filter { $0 }.count
        isLookingAtScreen = lookingCount > historySize / 2
    }
}

// MARK: - Vision Implementation (Fallback for non-Face ID devices)

class VisionGazeTracker: NSObject, GazeTracker {
    private(set) var isLookingAtScreen: Bool = true {
        didSet {
            if oldValue != isLookingAtScreen {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.onGazeUpdate?(self.isLookingAtScreen)
                }
            }
        }
    }
    var onGazeUpdate: ((Bool) -> Void)?

    private var landmarksRequest: VNDetectFaceLandmarksRequest?

    // Smoothing
    private var lookingHistory: [Bool] = []
    private let historySize = 5

    // Thresholds for eye analysis
    private let eyeOpenThreshold: CGFloat = 0.015  // Minimum vertical distance for "open"

    override init() {
        super.init()
        setupLandmarksDetection()
    }

    private func setupLandmarksDetection() {
        landmarksRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let self = self,
                  error == nil,
                  let results = request.results as? [VNFaceObservation],
                  let face = results.first,
                  let landmarks = face.landmarks else {
                self?.updateWithSmoothing(false)
                return
            }

            let looking = self.analyzeLandmarks(landmarks, in: face.boundingBox)
            self.updateWithSmoothing(looking)
        }
    }

    func start() {
        // Vision tracker processes frames passed to it via processPixelBuffer
        // Reset state
        lookingHistory.removeAll()
        isLookingAtScreen = true
    }

    func stop() {
        lookingHistory.removeAll()
        isLookingAtScreen = true
    }

    /// Process a video frame for gaze detection
    func processPixelBuffer(_ pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) {
        guard let request = landmarksRequest else { return }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])

        do {
            try handler.perform([request])
        } catch {
            // Silently handle - gaze detection is optional enhancement
        }
    }

    private func analyzeLandmarks(_ landmarks: VNFaceLandmarks2D, in boundingBox: CGRect) -> Bool {
        // Check if we have eye landmarks
        guard let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye else {
            return false
        }

        // Check if eyes are open
        let leftOpen = isEyeOpen(leftEye)
        let rightOpen = isEyeOpen(rightEye)

        // If both eyes are closed, not looking at screen
        if !leftOpen && !rightOpen {
            return false
        }

        // Check pupil positions if available
        if let leftPupil = landmarks.leftPupil,
           let rightPupil = landmarks.rightPupil {
            let leftCentered = isPupilCentered(eye: leftEye, pupil: leftPupil)
            let rightCentered = isPupilCentered(eye: rightEye, pupil: rightPupil)

            // At least one eye should have centered pupil
            return leftCentered || rightCentered
        }

        // If no pupil data, just check eyes are open
        return leftOpen || rightOpen
    }

    private func isEyeOpen(_ eye: VNFaceLandmarkRegion2D) -> Bool {
        let points = eye.normalizedPoints
        guard points.count >= 6 else { return true }  // Not enough points, assume open

        // Eye landmarks typically: corners and top/bottom edges
        // Calculate vertical extent
        let yValues = points.map { $0.y }
        guard let minY = yValues.min(), let maxY = yValues.max() else { return true }

        let verticalExtent = maxY - minY
        return verticalExtent > eyeOpenThreshold
    }

    private func isPupilCentered(eye: VNFaceLandmarkRegion2D, pupil: VNFaceLandmarkRegion2D) -> Bool {
        guard let pupilPoint = pupil.normalizedPoints.first else { return true }

        let eyePoints = eye.normalizedPoints
        guard !eyePoints.isEmpty else { return true }

        // Calculate eye center (only X needed for horizontal gaze detection)
        let eyeCenterX = eyePoints.map { $0.x }.reduce(0, +) / CGFloat(eyePoints.count)

        // Calculate eye width for normalization
        let xValues = eyePoints.map { $0.x }
        guard let minX = xValues.min(), let maxX = xValues.max() else { return true }
        let eyeWidth = maxX - minX
        guard eyeWidth > 0 else { return true }

        // Check if pupil is near center of eye
        let offsetFromCenter = abs(pupilPoint.x - eyeCenterX) / eyeWidth

        // Pupil is "centered" if within 30% of center
        return offsetFromCenter < 0.3
    }

    private func updateWithSmoothing(_ looking: Bool) {
        lookingHistory.append(looking)
        if lookingHistory.count > historySize {
            lookingHistory.removeFirst()
        }

        // Require majority of recent frames to agree
        let lookingCount = lookingHistory.filter { $0 }.count
        isLookingAtScreen = lookingCount > historySize / 2
    }
}
