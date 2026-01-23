import SwiftUI

struct PhotoDetailView: View {
    let photo: TrancePhoto
    @State private var image: UIImage?
    @State private var showShareSheet = false
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Photo display
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Info bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text(photo.capturedAt, style: .date)
                        Spacer()
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text(photo.capturedAt, style: .time)
                    }
                    .font(.subheadline)

                    if let preset = photo.presetName {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.secondary)
                            Text("Preset: \(preset)")
                        }
                        .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
            }
            .navigationTitle("Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(image == nil)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = image {
                    ShareSheet(items: [image])
                }
            }
            .confirmationDialog("Delete Photo", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    PhotoStorageManager.shared.deletePhoto(photo)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This photo will be permanently deleted.")
            }
        }
        .task {
            image = PhotoStorageManager.shared.loadImage(for: photo)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    PhotoDetailView(photo: TrancePhoto(filename: "test.jpg", presetName: "Birthday"))
}
