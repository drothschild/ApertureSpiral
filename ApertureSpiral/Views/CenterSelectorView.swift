import SwiftUI

struct CenterSelectorView: View {
    let imageData: Data
    @Binding var centerX: Double
    @Binding var centerY: Double
    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var circlePosition: CGPoint = .zero
    @State private var imageSize: CGSize = .zero
    @State private var displayedImageFrame: CGRect = .zero

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color.black.ignoresSafeArea()

                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .background(
                                GeometryReader { imageGeometry in
                                    Color.clear
                                        .onAppear {
                                            displayedImageFrame = imageGeometry.frame(in: .local)
                                            imageSize = uiImage.size
                                            // Initialize circle position to current center or middle of image
                                            let imageFrame = calculateImageFrame(containerSize: geometry.size, imageSize: uiImage.size)
                                            circlePosition = CGPoint(
                                                x: imageFrame.origin.x + imageFrame.width * centerX,
                                                y: imageFrame.origin.y + imageFrame.height * centerY
                                            )
                                        }
                                }
                            )

                        // Draggable circle overlay
                        Circle()
                            .strokeBorder(Color.yellow, lineWidth: 3)
                            .background(Circle().fill(Color.yellow.opacity(0.2)))
                            .frame(width: 60, height: 60)
                            .position(circlePosition)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let imageFrame = calculateImageFrame(containerSize: geometry.size, imageSize: uiImage.size)

                                        // Constrain to image bounds
                                        let newX = min(max(value.location.x, imageFrame.minX), imageFrame.maxX)
                                        let newY = min(max(value.location.y, imageFrame.minY), imageFrame.maxY)

                                        circlePosition = CGPoint(x: newX, y: newY)

                                        // Update normalized coordinates
                                        centerX = (newX - imageFrame.origin.x) / imageFrame.width
                                        centerY = (newY - imageFrame.origin.y) / imageFrame.height
                                    }
                            )

                        // Crosshairs
                        Path { path in
                            let imageFrame = calculateImageFrame(containerSize: geometry.size, imageSize: uiImage.size)
                            // Horizontal line
                            path.move(to: CGPoint(x: imageFrame.minX, y: circlePosition.y))
                            path.addLine(to: CGPoint(x: imageFrame.maxX, y: circlePosition.y))
                            // Vertical line
                            path.move(to: CGPoint(x: circlePosition.x, y: imageFrame.minY))
                            path.addLine(to: CGPoint(x: circlePosition.x, y: imageFrame.maxY))
                        }
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                    }
                }
            }
            .navigationTitle("Select Center")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSave()
                    }
                }
            }
        }
    }

    private func calculateImageFrame(containerSize: CGSize, imageSize: CGSize) -> CGRect {
        let aspectRatio = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height

        var imageFrame = CGRect.zero

        if aspectRatio > containerAspect {
            // Image is wider - fit to width
            let displayWidth = containerSize.width
            let displayHeight = displayWidth / aspectRatio
            imageFrame = CGRect(
                x: 0,
                y: (containerSize.height - displayHeight) / 2,
                width: displayWidth,
                height: displayHeight
            )
        } else {
            // Image is taller - fit to height
            let displayHeight = containerSize.height
            let displayWidth = displayHeight * aspectRatio
            imageFrame = CGRect(
                x: (containerSize.width - displayWidth) / 2,
                y: 0,
                width: displayWidth,
                height: displayHeight
            )
        }

        return imageFrame
    }
}

#Preview {
    CenterSelectorView(
        imageData: Data(),
        centerX: .constant(0.5),
        centerY: .constant(0.5)
    ) {
        print("Saved")
    }
}
