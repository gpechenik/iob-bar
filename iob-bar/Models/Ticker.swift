import Foundation
import Combine

/// Publishes the current Date on a recurring interval so views observing it
/// re-render and show updated decay-derived values (IOB, elapsed-since).
@MainActor
final class Ticker: ObservableObject {
    @Published var now = Date()
    private var timer: Timer?

    init(interval: TimeInterval = 60) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task { @MainActor [weak self] in
                self?.now = Date()
            }
        }
    }

    deinit { timer?.invalidate() }
}
