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
                    let colorOffset = Int(time * settings.colorFlowSpeed)

                    for layer in stride(from: settings.layerCount - 1, through: 0, by: -1) {
                        let layerRadius = radius * (0.5 + Double(layer) * 0.1)
                        let rotationOffset = time * (0.8 + Double(layer) * 0.5) * direction
                        let layerAlpha = 0.15 + (Double(layer) / Double(settings.layerCount)) * 0.25

                        // Color by layer: calculate once per layer
                        let layerColorIndex = ((layer - colorOffset) % colors.count + colors.count) % colors.count

                        for i in 0..<settings.bladeCount {
                            // Color by blade or by layer based on setting
                            let colorIndex = settings.colorByBlade
                                ? ((i - colorOffset) % colors.count + colors.count) % colors.count
                                : layerColorIndex
                            let color = colorComponents[colorIndex]

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

                    // Fill center gap when aperture is closing
                    drawCenterFill(context: context, cx: cx, cy: cy, radius: radius, apertureSize: apertureSize)

                    // Draw photo texture ON TOP of fill if available, otherwise draw aperture hole
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
                        // Draw center hole only when no photo is selected
                        drawApertureHole(context: context, cx: cx, cy: cy, radius: radius, apertureSize: apertureSize)
                    }

                    // Lens flare effect
                    if settings.lensFlareEnabled {
                        drawLensFlare(context: context, cx: cx, cy: cy, radius: radius, canvasSize: canvasSize)
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

        // Blade parameters - arcCenterX moves inward as aperture closes
        let arcCenterX = bladeRadius * (0.05 + 0.30 * apertureSize)
        let arcRadius = bladeRadius * (0.85 + apertureSize * 0.4)
        let thickness = radius * (0.12 + Double(layerIndex) * 0.02)

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
        // Use a color that blends with the blades
        let colorIndex = Int(time * settings.colorFlowSpeed) % colorComponents.count
        let color = colorComponents[colorIndex]
        let solidColor = Color(red: color.r/255, green: color.g/255, blue: color.b/255)

        // Different behavior depending on whether photo is present
        if settings.selectedPhotoData != nil {
            // With photo: draw ring that covers from photo edge inward
            // MUST match the exact photoRadius calculation from drawPhotoTexture
            let photoRadius = radius * settings.apertureSize * 0.43
            // innerRadius shrinks with breathing animation - this is what's visible of the photo
            let innerRadius = photoRadius * apertureSize

            guard photoRadius > 1 && innerRadius >= 0 else { return }

            // Only draw if there's actually a ring to show (innerRadius < photoRadius)
            if innerRadius < photoRadius {
                // Create a ring path using even-odd fill rule
                var ringPath = Path()

                // Outer circle
                ringPath.addEllipse(in: CGRect(
                    x: cx - photoRadius,
                    y: cy - photoRadius,
                    width: photoRadius * 2,
                    height: photoRadius * 2
                ))

                // Inner circle (will be subtracted with even-odd rule)
                ringPath.addEllipse(in: CGRect(
                    x: cx - innerRadius,
                    y: cy - innerRadius,
                    width: innerRadius * 2,
                    height: innerRadius * 2
                ))

                // Fill using even-odd rule to create ring
                context.fill(ringPath, with: .color(solidColor), style: FillStyle(eoFill: true))
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

    private func drawLensFlare(
        context: GraphicsContext,
        cx: CGFloat,
        cy: CGFloat,
        radius: CGFloat,
        canvasSize: CGSize
    ) {
        let flareAngle = time * 0.5
        let flareX = cx + cos(flareAngle) * radius * 0.3
        let flareY = cy + sin(flareAngle) * radius * 0.3

        let flareAlpha = 0.05 + sin(time * 3) * 0.02
        let gradient = Gradient(stops: [
            .init(color: .white.opacity(flareAlpha), location: 0),
            .init(color: Color(red: 248/255, green: 181/255, blue: 0/255).opacity(0.02), location: 0.5),
            .init(color: .clear, location: 1),
        ])

        let rect = CGRect(origin: .zero, size: canvasSize)
        context.fill(
            Path(rect),
            with: .radialGradient(gradient, center: CGPoint(x: flareX, y: flareY), startRadius: 0, endRadius: radius * 0.3)
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
        // Use fixed radius based on maximum aperture size (settings.apertureSize)
        // Photo stays constant size, only gets covered by fill color
        let photoRadius = radius * settings.apertureSize * 0.43

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

        // Create a circular clipping path
        let circlePath = Path(ellipseIn: destRect)

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
