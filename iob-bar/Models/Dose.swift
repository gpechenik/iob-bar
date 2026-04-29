import Foundation

struct Dose: Codable, Identifiable, Equatable {
    let id: UUID
    let amount: Double
    let timestamp: Date
    let note: String?

    init(id: UUID = UUID(), amount: Double, timestamp: Date = Date(), note: String? = nil) {
        self.id = id
        self.amount = amount
        self.timestamp = timestamp
        self.note = note
    }
}
