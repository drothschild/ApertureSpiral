import Foundation

struct TrancePhoto: Codable, Identifiable {
    let id: UUID
    let filename: String
    let capturedAt: Date
    let presetName: String?

    init(id: UUID = UUID(), filename: String, capturedAt: Date = Date(), presetName: String? = nil) {
        self.id = id
        self.filename = filename
        self.capturedAt = capturedAt
        self.presetName = presetName
    }
}
