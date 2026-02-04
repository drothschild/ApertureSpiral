import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settings: SpiralSettings

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showCenterSelector = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let imageData = selectedImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .cornerRadius(12)

                    Button("Select Center Point") {
                        showCenterSelector = true
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            Text("Select a Photo")
                                .font(.headline)
                            Text("Choose a photo from your library to use in the spiral")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Photo Selector")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
            .sheet(isPresented: $showCenterSelector) {
                if let imageData = selectedImageData {
                    CenterSelectorView(
                        imageData: imageData,
                        centerX: $settings.photoCenterX,
                        centerY: $settings.photoCenterY
                    ) {
                        settings.selectedPhotoData = imageData
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PhotoPickerView(settings: SpiralSettings.shared)
}
