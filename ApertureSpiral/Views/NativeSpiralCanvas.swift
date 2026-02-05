import SwiftUI

struct NativeSpiralCanvas: View {
    @ObservedObject var settings: SpiralSettings
    @Binding var holeDiameter: CGFloat
    @Binding var maxHoleDiameter: CGFloat

    // Animation state
    @State private var time: Double = 0
    @State private var direction: Double = 1

    // Breathing parameters
    private let breathCycleSeconds: Double = 8.0
    private let breathDepth: Double = 1.0

    // Color palette from settings
    private var colors: [Color] {
        settings.colorPalette.swiftUIColors
    }

    private var colorComponents: [(r: Double, g: Double, b: Double)] {
        settings.colorPalette.colorComponents
    }

    // Interpolate between two colors for smooth transitions
    private func lerpColor(
        from: (r: Double, g: Double, b: Double),
        to: (r: Double, g: Double, b: Double),
        t: Double
    ) -> (r: Double, g: Double, b: Double) {
        let clampedT = max(0, min(1, t))
        return (
            r: from.r + (to.r - from.r) * clampedT,
            g: from.g + (to.g - from.g) * clampedT,
            b: from.b + (to.b - from.b) * clampedT
        )
    }

    // Get interpolated color at a fractional position in the palette
    private func getInterpolatedColor(at position: Double) -> (r: Double, g: Double, b: Double) {
        let count = colorComponents.count
        guard count > 0 else { return (r: 255, g: 255, b: 255) }

        // Normalize position to [0, count) range
        var normalizedPos = position.truncatingRemainder(dividingBy: Double(count))
        if normalizedPos < 0 { normalizedPos += Double(count) }

        let index = Int(normalizedPos)
        let fraction = normalizedPos - Double(index)

        let currentColor = colorComponents[index % count]
        let nextColor = colorComponents[(index + 1) % count]

        return lerpColor(from: currentColor, to: nextColor, t: fraction)
    }

    var body: some View {
        GeometryReader { geometry in
            // Use screen bounds to ensure full coverage regardless of safe areas
            // Multiplier needs to be large enough so blades (which reach ~90% of radius) cover corners
            let screenSize = UIScreen.main.bounds.size
            let size = max(screenSize.width, screenSize.height) * 1.8

            TimelineView(.animation(minimumInterval: 1/60)) { timeline in
                Canvas { context, canvasSize in
                    let cx = canvasSize.width / 2
                    let cy = canvasSize.height / 2
                    let radius = min(cx, cy)

                    // Calculate breathing aperture
                    let breathPhase = (time / breathCycleSeconds) * .pi * 2
                    let breathAmount = (cos(breathPhase) + 1) / 2
                    let apertureSize = settings.apertureSize * (1 - breathDepth * breathAmount)

                    // Update hole diameter for camera preview sync
                    // Use 0.38 (vs 0.43 for visual aperture) to ensure preview stays within aperture bounds
                    let cameraHoleRadius = radius * apertureSize * 0.38
                    let currentCameraHoleDiameter = cameraHoleRadius * 2
                    let maxCameraHoleRadius = radius * settings.apertureSize * 0.38
                    let currentMaxCameraHoleDiameter = maxCameraHoleRadius * 2

                    DispatchQueue.main.async {
                        holeDiameter = currentCameraHoleDiameter
                        maxHoleDiameter = currentMaxCameraHoleDiameter
                    }

                    // Background
                    let bgRect = CGRect(origin: .zero, size: canvasSize)
                    context.fill(Path(bgRect), with: .color(Color(red: 0.04, green: 0.04, blue: 0.07)))

                    // Outer glow
                    drawOuterGlow(context: context, cx: cx, cy: cy, radius: radius, canvasSize: canvasSize)

                    // Draw layers from back to front
                    // Use fractional offset for smooth color transitions
                    let colorOffset = time * settings.colorFlowSpeed

                    for layer in stride(from: settings.layerCount - 1, through: 0, by: -1) {
                        let layerRadius = radius * (0.5 + Double(layer) * 0.1)
                        let rotationOffset = time * (0.8 + Double(layer) * 0.5) * direction
                        let layerAlpha = 0.15 + (Double(layer) / Double(settings.layerCount)) * 0.25

                        // Color by layer: calculate once per layer using interpolation
                        let layerColorPosition = Double(layer) - colorOffset

                        for i in 0..<settings.bladeCount {
                            // Color by blade or by layer based on setting, with smooth interpolation
                            let colorPosition = settings.colorByBlade
                                ? Double(i) - colorOffset
                                : layerColorPosition
                            let color = getInterpolatedColor(at: colorPosition)

                            let baseAngle = (Double(i) / Double(settings.bladeCount)) * .pi * 2
                            let angle = baseAngle + rotationOffset + Double(layer) * 0.1
                            let pulseAlpha = layerAlpha + sin(time * 1.5 + Double(i) * 0.5 + Double(layer)) * 0.05

                            drawBlade(
                                context: context,
                                cx: cx,
                                cy: cy,
                                angle: angle,
                                radius: layerRadius,
                                color: color,
                                alpha: pulseAlpha,
                                layerIndex: layer,
                                apertureSize: apertureSize
                            )
                        }
                    }

                    // Draw center content based on spiralCenterMode
                    switch settings.spiralCenterMode {
                    case .photo:
                        if let photoData = settings.selectedPhotoData,
                           let uiImage = UIImage(data: photoData),
                           let cgImage = uiImage.cgImage {
                            drawPhotoTexture(
                                context: context,
                                image: cgImage,
                                cx: cx,
                                cy: cy,
                                radius: radius,
                                apertureSize: apertureSize
                            )
                        } else {
                            // Photo mode but no photo selected - show aperture hole
                            drawApertureHole(context: context, cx: cx, cy: cy, radius: radius, apertureSize: apertureSize)
                        }
                    case .mirror:
                        // Mirror mode - camera preview is handled in SpiralView, draw nothing here
                        break
                    case .none:
                        // None mode - show dark aperture hole
                        drawApertureHole(context: context, cx: cx, cy: cy, radius: radius, apertureSize: apertureSize)
                    }

                }
                .onChange(of: timeline.date) { _, _ in
                    if !settings.spiralFrozen {
                        time += 0.016 * settings.speed
                    }
                }
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .background(Color(red: 0.04, green: 0.04, blue: 0.07))
        .ignoresSafeArea()
        .onTapGesture {
            direction *= -1
        }
    }

    private func drawBlade(
        context: GraphicsContext,
        cx: CGFloat,
        cy: CGFloat,
        angle: Double,
        radius: CGFloat,
        color: (r: Double, g: Double, b: Double),
        alpha: Double,
        layerIndex: Int,
        apertureSize: Double
    ) {
        let bladeRadius = radius * (0.4 + Double(layerIndex) * 0.12)
        let thickness = radius * (0.12 + Double(layerIndex) * 0.02)

        // Blade parameters - blades converge to center when aperture closes
        // The innermost point of blade is at: arcCenterX - innerRadius
        // where innerRadius = arcRadius - thickness/2
        // So innermost point = arcCenterX - arcRadius + thickness/2
        // We want: innermost point = openingRadius
        // Therefore: arcCenterX = openingRadius + arcRadius - thickness/2
        // And: arcRadius = openingRadius + thickness/2
        // So: arcCenterX = openingRadius + (openingRadius + thickness/2) - thickness/2 = 2 * openingRadius
        let maxOpening = bladeRadius * 0.42
        let openingRadius = maxOpening * apertureSize
        let arcRadius = openingRadius + thickness / 2
        let arcCenterX = openingRadius + arcRadius - thickness / 2  // = 2 * openingRadius

        // Arc sweep
        let arcSweep = Double.pi * (1.2 + 0.8 / Double(settings.bladeCount))
        let startAngle = Double.pi * 0.5 - arcSweep / 2
        let endAngle = Double.pi * 0.5 + arcSweep / 2

        // Slant offset for iris blade effect
        let slantOffset = Double.pi * 0.12

        var path = Path()

        // Outer arc
        let outerRadius = arcRadius + thickness / 2
        let innerRadius = arcRadius - thickness / 2

        // Start point on outer arc
        let outerStartAngle = startAngle - slantOffset
        path.move(to: CGPoint(
            x: arcCenterX + cos(outerStartAngle) * outerRadius,
            y: sin(outerStartAngle) * outerRadius
        ))

        // Outer arc
        path.addArc(
            center: CGPoint(x: arcCenterX, y: 0),
            radius: outerRadius,
            startAngle: .radians(outerStartAngle),
            endAngle: .radians(endAngle),
            clockwise: false
        )

        // Line to inner arc at end
        let innerEndAngle = endAngle + slantOffset
        path.addLine(to: CGPoint(
            x: arcCenterX + cos(innerEndAngle) * innerRadius,
            y: sin(innerEndAngle) * innerRadius
        ))

        // Inner arc (clockwise = reversed)
        path.addArc(
            center: CGPoint(x: arcCenterX, y: 0),
            radius: innerRadius,
            startAngle: .radians(innerEndAngle),
            endAngle: .radians(startAngle),
            clockwise: true
        )

        path.closeSubpath()

        // Transform for rotation and position
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: cx, y: cy)
        transform = transform.rotated(by: angle)

        let transformedPath = path.applying(transform)

        // Create gradient
        let startPoint = CGPoint(
            x: cx + cos(angle) * (arcCenterX + cos(startAngle) * arcRadius),
            y: cy + sin(angle) * (arcCenterX + cos(startAngle) * arcRadius)
        )
        let endPoint = CGPoint(
            x: cx + cos(angle) * (arcCenterX + cos(endAngle) * arcRadius),
            y: cy + sin(angle) * (arcCenterX + cos(endAngle) * arcRadius)
        )

        let gradient = Gradient(stops: [
            .init(color: Color(red: color.r/255, green: color.g/255, blue: color.b/255).opacity(alpha * 0.2), location: 0),
            .init(color: Color(red: color.r/255, green: color.g/255, blue: color.b/255).opacity(alpha * 0.8), location: 0.5),
            .init(color: Color(red: color.r/255, green: color.g/255, blue: color.b/255).opacity(alpha * 0.2), location: 1),
        ])

        context.fill(
            transformedPath,
            with: .linearGradient(gradient, startPoint: startPoint, endPoint: endPoint)
        )

        // Edge highlight
        context.stroke(
            transformedPath,
            with: .color(.white.opacity(alpha * 0.25)),
            lineWidth: 7
        )
    }

    private func drawCenterFill(
        context: GraphicsContext,
        cx: CGFloat,
        cy: CGFloat,
        radius: CGFloat,
        apertureSize: Double
    ) {
        // Use a color that blends with the blades (with smooth interpolation)
        let colorPosition = time * settings.colorFlowSpeed
        let color = getInterpolatedColor(at: colorPosition)
        let solidColor = Color(red: color.r/255, green: color.g/255, blue: color.b/255)

        // Different behavior depending on spiral center mode
        if settings.spiralCenterMode == .photo && settings.selectedPhotoData != nil {
            // With photo: draw thin ring that covers from photo edge inward
            // MUST match the exact photoRadius calculation from drawPhotoTexture
            let photoRadius = radius * settings.apertureSize * 0.43

            // Calculate how much of the photo to cover based on aperture closing
            // When aperture is fully open (apertureSize = 1.0), no fill
            // When aperture is fully closed (apertureSize = 0.0), fill covers entire photo
            // Use cubed falloff so fill stays very thin and grows slowly from edge
            let fillAmount = 1.0 - apertureSize  // 0.0 = no fill, 1.0 = full fill
            let fillDepth = fillAmount * fillAmount * fillAmount  // Cube it for very slow growth
            let innerRadius = photoRadius * (1.0 - fillDepth)

            guard photoRadius > 1 && innerRadius >= 0 else { return }

            // Only draw if there's actually a ring to show (innerRadius < photoRadius)
            if fillAmount > 0.01 {
                // Create circular clipping path that matches photo boundary exactly
                let clipPath = Path(ellipseIn: CGRect(
                    x: cx - photoRadius,
                    y: cy - photoRadius,
                    width: photoRadius * 2,
                    height: photoRadius * 2
                ))

                // Draw fill within clipping region
                context.drawLayer { layerContext in
                    // Clip to photo circle
                    layerContext.clip(to: clipPath)

                    // Use radial gradient from transparent at inner radius to solid
                    let gradient = Gradient(stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .clear, location: innerRadius / photoRadius),
                        .init(color: solidColor, location: innerRadius / photoRadius + 0.01),
                        .init(color: solidColor, location: 1.0),
                    ])

                    let fillPath = Path(ellipseIn: CGRect(
                        x: cx - photoRadius,
                        y: cy - photoRadius,
                        width: photoRadius * 2,
                        height: photoRadius * 2
                    ))

                    layerContext.fill(
                        fillPath,
                        with: .radialGradient(
                            gradient,
                            center: CGPoint(x: cx, y: cy),
                            startRadius: 0,
                            endRadius: photoRadius
                        )
                    )
                }
            }
        } else {
            // Without photo: small fill for blade gaps (original behavior)
            let maxFillRadius = radius * 0.15
            let fillRadius = maxFillRadius * (1 - apertureSize)

            guard fillRadius > 1 else { return }

            let gradient = Gradient(stops: [
                .init(color: solidColor.opacity(0.6), location: 0),
                .init(color: solidColor.opacity(0.3), location: 0.7),
                .init(color: solidColor.opacity(0), location: 1),
            ])

            let fillPath = Path(ellipseIn: CGRect(
                x: cx - fillRadius,
                y: cy - fillRadius,
                width: fillRadius * 2,
                height: fillRadius * 2
            ))

            context.fill(
                fillPath,
                with: .radialGradient(gradient, center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: fillRadius)
            )
        }
    }

    private func drawApertureHole(
        context: GraphicsContext,
        cx: CGFloat,
        cy: CGFloat,
        radius: CGFloat,
        apertureSize: Double
    ) {
        let holeRadius = radius * apertureSize * 0.43

        // Skip drawing when aperture is fully closed
        guard holeRadius > 1 else { return }

        // Dark center gradient
        let gradient = Gradient(stops: [
            .init(color: Color(red: 5/255, green: 5/255, blue: 10/255).opacity(0.95), location: 0),
            .init(color: Color(red: 10/255, green: 10/255, blue: 20/255).opacity(0.9), location: 0.7),
            .init(color: Color(red: 20/255, green: 20/255, blue: 40/255).opacity(0.5), location: 1),
        ])

        let holePath = Path(ellipseIn: CGRect(
            x: cx - holeRadius,
            y: cy - holeRadius,
            width: holeRadius * 2,
            height: holeRadius * 2
        ))

        context.fill(
            holePath,
            with: .radialGradient(gradient, center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: holeRadius)
        )

        // Inner glow ring
        let glowRadius = holeRadius * 0.9
        let glowPath = Path(ellipseIn: CGRect(
            x: cx - glowRadius,
            y: cy - glowRadius,
            width: glowRadius * 2,
            height: glowRadius * 2
        ))

        let glowAlpha = 0.1 + sin(time * 2) * 0.05
        context.stroke(
            glowPath,
            with: .color(Color(red: 248/255, green: 181/255, blue: 0/255).opacity(glowAlpha)),
            lineWidth: 2
        )
    }

    private func drawOuterGlow(
        context: GraphicsContext,
        cx: CGFloat,
        cy: CGFloat,
        radius: CGFloat,
        canvasSize: CGSize
    ) {
        let gradient = Gradient(stops: [
            .init(color: .clear, location: 0),
            .init(color: Color(red: 248/255, green: 181/255, blue: 0/255).opacity(0.02), location: 0.8),
            .init(color: Color(red: 247/255, green: 37/255, blue: 133/255).opacity(0.05), location: 1),
        ])

        let rect = CGRect(origin: .zero, size: canvasSize)
        context.fill(
            Path(rect),
            with: .radialGradient(gradient, center: CGPoint(x: cx, y: cy), startRadius: radius * 0.5, endRadius: radius * 1.1)
        )
    }

    private func drawPhotoTexture(
        context: GraphicsContext,
        image: CGImage,
        cx: CGFloat,
        cy: CGFloat,
        radius: CGFloat,
        apertureSize: Double
    ) {
        // Photo stays at fixed maximum size, gets clipped by aperture
        // Use 0.38 to match camera preview size (both should show same aperture opening)
        let maxPhotoRadius = radius * settings.apertureSize * 0.38
        let photoRadius = maxPhotoRadius  // Fixed at maximum opening size

        // Calculate the clipping radius based on the actual aperture opening
        let apertureOpening = radius * apertureSize * 0.38

        guard photoRadius > 1 else { return }

        // Get image dimensions
        let imageWidth = CGFloat(image.width)
        let imageHeight = CGFloat(image.height)

        // Calculate the center point in pixels
        let centerXPixels = imageWidth * settings.photoCenterX
        let centerYPixels = imageHeight * settings.photoCenterY

        // Calculate the size we need to display (fixed size)
        let displayDiameter = photoRadius * 2

        // Scale factor: how much of the image should be visible
        // We'll use a conservative scale that shows enough context
        let scaleToFit = displayDiameter / min(imageWidth, imageHeight)

        // Calculate source rect: the portion of the image to sample
        // We want to sample around the center point
        let sourceWidth = displayDiameter / scaleToFit
        let sourceHeight = displayDiameter / scaleToFit

        let sourceX = max(0, min(imageWidth - sourceWidth, centerXPixels - sourceWidth / 2))
        let sourceY = max(0, min(imageHeight - sourceHeight, centerYPixels - sourceHeight / 2))

        let sourceRect = CGRect(x: sourceX, y: sourceY, width: sourceWidth, height: sourceHeight)

        // Destination rect: where to draw on the canvas (centered, fixed size)
        let destRect = CGRect(
            x: cx - photoRadius,
            y: cy - photoRadius,
            width: displayDiameter,
            height: displayDiameter
        )

        // Crop the image to the source rect
        guard let croppedImage = image.cropping(to: sourceRect) else { return }

        // Create a circular clipping path that matches the aperture opening
        let clipDiameter = apertureOpening * 2
        let clipRect = CGRect(
            x: cx - apertureOpening,
            y: cy - apertureOpening,
            width: clipDiameter,
            height: clipDiameter
        )
        let circlePath = Path(ellipseIn: clipRect)

        // Apply clipping and draw
        context.drawLayer { layerContext in
            layerContext.clip(to: circlePath)
            layerContext.draw(Image(decorative: croppedImage, scale: 1.0), in: destRect)
        }
    }
}

#Preview {
    NativeSpiralCanvas(
        settings: SpiralSettings.shared,
        holeDiameter: .constant(100),
        maxHoleDiameter: .constant(150)
    )
}
