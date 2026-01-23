import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer?
    var eyeCenterOffset: CGPoint = .zero
    var eyeCenteringEnabled: Bool = true

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        // Use dark background matching the spiral to hide any camera layer gaps
        view.backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.07, alpha: 1.0)
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
    private let maskLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.mask = maskLayer
        setupOrientationObserver()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        clipsToBounds = true
        layer.mask = maskLayer
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
        // Update circular mask path
        maskLayer.path = UIBezierPath(ovalIn: bounds).cgPath
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

        // Scale factor provides margin for eye-centering panning without excessive zoom
        // 1.15 = 15% larger, balanced between coverage and natural framing
        let scale: CGFloat = 1.15
        let scaledWidth = bounds.width * scale
        let scaledHeight = bounds.height * scale

        // Maximum offset we can safely apply (use most of available margin)
        let maxOffset = bounds.width * (scale - 1.0) / 2.0 * 0.9

        // Calculate offset in pixels to shift the face to center
        // Reduced multiplier (0.3) for subtler movement that stays within margin
        let rawOffsetX = currentEyeOffset.x * bounds.width * 0.3
        let rawOffsetY = -currentEyeOffset.y * bounds.height * 0.3  // Flip Y for UIKit

        // Clamp offsets to prevent exposing camera layer edges
        let offsetX = max(-maxOffset, min(maxOffset, rawOffsetX))
        let offsetY = max(-maxOffset, min(maxOffset, rawOffsetY))

        // Center the oversized layer by default
        let baseX = (bounds.width - scaledWidth) / 2
        let baseY = (bounds.height - scaledHeight) / 2

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
