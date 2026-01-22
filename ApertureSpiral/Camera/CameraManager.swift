import AVFoundation
import UIKit
import Combine
import Vision

class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var isSessionRunning = false
    @Published var eyeCenterOffset: CGPoint = .zero
    @Published var faceDetected: Bool = false

    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var photoCaptureCompletion: ((UIImage?) -> Void)?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let videoDataQueue = DispatchQueue(label: "video.data.queue", qos: .userInteractive)

    private var faceDetectionRequest: VNDetectFaceRectanglesRequest?
    private var frameCounter = 0
    private var smoothedOffset: CGPoint = .zero

    var previewLayer: AVCaptureVideoPreviewLayer?

    override init() {
        super.init()
        checkAuthorizationStatus()
        setupFaceDetection()
    }

    private func setupFaceDetection() {
        faceDetectionRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
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
                }
                return
            }

            let offset = self.calculateFaceCenterOffset(from: face)
            DispatchQueue.main.async {
                self.faceDetected = true
                // Exponential smoothing to prevent jitter
                self.smoothedOffset = CGPoint(
                    x: self.smoothedOffset.x * 0.7 + offset.x * 0.3,
                    y: self.smoothedOffset.y * 0.7 + offset.y * 0.3
                )
                self.eyeCenterOffset = self.smoothedOffset
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
        captureSession.sessionPreset = .photo

        // Front camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            captureSession.commitConfiguration()
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
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
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        photoCaptureCompletion = completion
        sessionQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let settings = AVCapturePhotoSettings()
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

extension CameraManager: @preconcurrency AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            DispatchQueue.main.async { [weak self] in
                self?.photoCaptureCompletion?(nil)
            }
            return
        }

        // Get the correct orientation based on device orientation (front camera needs mirroring)
        let deviceOrientation = UIDevice.current.orientation
        let imageOrientation: UIImage.Orientation

        switch deviceOrientation {
        case .portrait:
            imageOrientation = .leftMirrored
        case .portraitUpsideDown:
            imageOrientation = .rightMirrored
        case .landscapeLeft:
            imageOrientation = .downMirrored
        case .landscapeRight:
            imageOrientation = .upMirrored
        default:
            imageOrientation = .leftMirrored
        }

        let correctedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: imageOrientation)

        DispatchQueue.main.async { [weak self] in
            self?.photoCaptureCompletion?(correctedImage)
        }
    }
}

extension CameraManager: @preconcurrency AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Process every 3rd frame to reduce CPU load
        frameCounter += 1
        guard frameCounter % 3 == 0 else { return }

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
