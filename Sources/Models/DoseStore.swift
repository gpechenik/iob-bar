import Foundation
import Combine

@MainActor
final class DoseStore: ObservableObject {
    @Published private(set) var doses: [Dose] = []
    @Published var lastDoseAmount: Double = 1.0

    init() { load() }

    func add(amount: Double, at timestamp: Date = Date(), note: String? = nil) {
        doses.append(Dose(amount: amount, timestamp: timestamp, note: note))
        lastDoseAmount = amount
        save()
    }

    func remove(_ dose: Dose) {
        doses.removeAll { $0.id == dose.id }
        save()
    }

    /// Drop doses older than the action-duration window so the JSON file
    /// stays tiny over time. Called on app launch and when the popover opens.
    func prune(actionDuration: TimeInterval, now: Date = Date()) {
        let before = doses.count
        doses = IOBCalculator.activeDoses(doses, actionDuration: actionDuration, now: now)
        if doses.count != before { save() }
    }

    private func load() {
        guard let data = try? Data(contentsOf: AppPaths.dosesFile),
              let decoded = try? JSONDecoder.iso.decode([Dose].self, from: data) else { return }
        doses = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder.iso.encode(doses) else { return }
        try? data.write(to: AppPaths.dosesFile)
    }
}
