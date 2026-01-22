import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer?
    var eyeCenterOffset: CGPoint = .zero
    var eyeCenteringEnabled: Bool = true

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.updatePreviewLayer(previewLayer)
        uiView.updateEyeCenterOffset(eyeCenteringEnabled ? eyeCenterOffset : .zero)
    }
}

class CameraPreviewUIView: UIView {
    private var currentPreviewLayer: AVCaptureVideoPreviewLayer?
    private var currentEyeOffset: CGPoint = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setupOrientationObserver()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        clipsToBounds = true
        setupOrientationObserver()
    }

    private func setupOrientationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func orientationDidChange() {
        updatePreviewOrientation()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Disable implicit animations to prevent panning/jumping during resize
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updatePreviewLayerFrame()
        CATransaction.commit()
    }

    func updateEyeCenterOffset(_ offset: CGPoint) {
        guard offset != currentEyeOffset else { return }
        currentEyeOffset = offset
        // Use smooth animation for offset changes
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.15)
        updatePreviewLayerFrame()
        CATransaction.commit()
    }

    private func updatePreviewLayerFrame() {
        guard let layer = currentPreviewLayer else { return }

        // Make layer slightly larger than bounds so we have extra content to pan
        // 1.15 = 15% larger, enough room to shift without excessive zoom
        let scale: CGFloat = 1.15
        let scaledWidth = bounds.width * scale
        let scaledHeight = bounds.height * scale

        // Center the oversized layer by default
        let baseX = (bounds.width - scaledWidth) / 2
        let baseY = (bounds.height - scaledHeight) / 2

        // Calculate offset in pixels to shift the face to center
        // Offset is normalized (-0.3 to 0.3), scale down for subtler movement
        let offsetX = currentEyeOffset.x * bounds.width * 0.5
        let offsetY = -currentEyeOffset.y * bounds.height * 0.5  // Flip Y for UIKit

        layer.frame = CGRect(
            x: baseX + offsetX,
            y: baseY + offsetY,
            width: scaledWidth,
            height: scaledHeight
        )
    }

    func updatePreviewLayer(_ layer: AVCaptureVideoPreviewLayer?) {
        if currentPreviewLayer !== layer {
            currentPreviewLayer?.removeFromSuperlayer()
            currentPreviewLayer = layer

            if let layer = layer {
                layer.frame = bounds
                self.layer.addSublayer(layer)
                updatePreviewOrientation()
            }
        }
    }

    private func updatePreviewOrientation() {
        guard let connection = currentPreviewLayer?.connection,
              connection.isVideoRotationAngleSupported(0) else { return }

        let deviceOrientation = UIDevice.current.orientation
        let rotationAngle: CGFloat

        switch deviceOrientation {
        case .portrait:
            rotationAngle = 90
        case .portraitUpsideDown:
            rotationAngle = 270
        case .landscapeLeft:
            rotationAngle = 180
        case .landscapeRight:
            rotationAngle = 0
        default:
            rotationAngle = 90
        }

        if connection.isVideoRotationAngleSupported(rotationAngle) {
            connection.videoRotationAngle = rotationAngle
        }
    }
}
