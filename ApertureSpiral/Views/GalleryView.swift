import SwiftUI

struct GalleryView: View {
    @StateObject private var storageManager = PhotoStorageManager.shared
    @State private var selectedPhoto: TrancePhoto?

    let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                if storageManager.photos.isEmpty {
                    ContentUnavailableView(
                        "No Trance Photos",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("Photos captured during spiral sessions will appear here.\n\nSet an auto-capture timer in the spiral settings to take photos automatically.")
                    )
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(storageManager.photos) { photo in
                            PhotoThumbnailView(photo: photo)
                                .aspectRatio(1, contentMode: .fill)
                                .clipped()
                                .onTapGesture {
                                    selectedPhoto = photo
                                }
                        }
                    }
                    .padding(4)
                }
            }
            .navigationTitle("Trance Photos")
            .sheet(item: $selectedPhoto) { photo in
                PhotoDetailView(photo: photo)
            }
        }
    }
}

struct PhotoThumbnailView: View {
    let photo: TrancePhoto
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .tint(.white)
                    )
            }
        }
        .task {
            image = PhotoStorageManager.shared.loadImage(for: photo)
        }
    }
}

#Preview {
    GalleryView()
}
