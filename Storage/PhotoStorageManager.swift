import Foundation
import UIKit
import Photos
import Combine

class PhotoStorageManager: ObservableObject {
    static let shared = PhotoStorageManager()

    @Published var photos: [TrancePhoto] = []

    let photosDirectory: URL
    private let manifestURL: URL

    private init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        photosDirectory = documents.appendingPathComponent("TrancePhotos")
        manifestURL = photosDirectory.appendingPathComponent("manifest.json")

        try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        loadManifest()
    }

    /// Creates an instance for testing with a custom directory
    init(forTesting directory: URL) {
        photosDirectory = directory
        manifestURL = directory.appendingPathComponent("manifest.json")
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        loadManifest()
    }

    /// Clears all photos (for testing)
    func reset() {
        for photo in photos {
            let url = photosDirectory.appendingPathComponent(photo.filename)
            try? FileManager.default.removeItem(at: url)
        }
        photos = []
        try? FileManager.default.removeItem(at: manifestURL)
    }

    func savePhoto(_ image: UIImage, presetName: String?) -> TrancePhoto? {
        let id = UUID()
        let filename = "\(id.uuidString).jpg"
        let url = photosDirectory.appendingPathComponent(filename)

        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }

        do {
            try data.write(to: url)
            let photo = TrancePhoto(id: id, filename: filename, capturedAt: Date(), presetName: presetName)
            photos.insert(photo, at: 0)
            saveManifest()
            return photo
        } catch {
            print("Failed to save photo: \(error)")
            return nil
        }
    }

    func deletePhoto(_ photo: TrancePhoto) {
        let url = photosDirectory.appendingPathComponent(photo.filename)
        try? FileManager.default.removeItem(at: url)
        photos.removeAll { $0.id == photo.id }
        saveManifest()
    }

    func loadImage(for photo: TrancePhoto) -> UIImage? {
        let url = photosDirectory.appendingPathComponent(photo.filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func exportToPhotosLibrary(_ photo: TrancePhoto, completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            guard let image = self.loadImage(for: photo) else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                DispatchQueue.main.async { completion(success) }
            }
        }
    }

    private func loadManifest() {
        guard let data = try? Data(contentsOf: manifestURL),
              let manifest = try? JSONDecoder().decode([TrancePhoto].self, from: data) else {
            photos = []
            return
        }
        photos = manifest.sorted { $0.capturedAt > $1.capturedAt }
    }

    private func saveManifest() {
        guard let data = try? JSONEncoder().encode(photos) else { return }
        try? data.write(to: manifestURL)
    }
}
