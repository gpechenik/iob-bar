import Foundation

enum IOBCalculator {
    /// Total IOB summed across all doses at `now`, weighted by each dose's
    /// remaining fraction per the given pharmacokinetic model.
    static func currentIOB(doses: [Dose], model: InsulinModel, now: Date = Date()) -> Double {
        doses.reduce(0) { sum, dose in
            let elapsed = now.timeIntervalSince(dose.timestamp)
            return sum + dose.amount * model.fractionRemaining(at: elapsed)
        }
    }

    /// Doses still within the action-duration window. Used both to render the
    /// "active doses" list and to prune persistent storage.
    static func activeDoses(_ doses: [Dose], actionDuration: TimeInterval, now: Date = Date()) -> [Dose] {
        doses.filter { now.timeIntervalSince($0.timestamp) < actionDuration }
    }
}
