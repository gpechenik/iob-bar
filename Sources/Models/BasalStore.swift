import Foundation
import Combine

@MainActor
final class BasalStore: ObservableObject {
    @Published private(set) var morningTaken: Date?
    @Published private(set) var eveningTaken: Date?
    @Published private(set) var dailyTaken: Date?

    init() {
        load()
        rolloverIfNewDay()
    }

    func markMorning(at date: Date = Date()) { morningTaken = date; save() }
    func markEvening(at date: Date = Date()) { eveningTaken = date; save() }
    func markDaily(at date: Date = Date()) { dailyTaken = date; save() }

    func clearMorning() { morningTaken = nil; save() }
    func clearEvening() { eveningTaken = nil; save() }
    func clearDaily()   { dailyTaken = nil; save() }

    /// Reset stamps that aren't from the current calendar day.
    func rolloverIfNewDay(now: Date = Date()) {
        let cal = Calendar.current
        var changed = false
        if let d = morningTaken, !cal.isDate(d, inSameDayAs: now) { morningTaken = nil; changed = true }
        if let d = eveningTaken, !cal.isDate(d, inSameDayAs: now) { eveningTaken = nil; changed = true }
        if let d = dailyTaken,   !cal.isDate(d, inSameDayAs: now) { dailyTaken = nil; changed = true }
        if changed { save() }
    }

    private struct Snapshot: Codable {
        var morningTaken: Date?
        var eveningTaken: Date?
        var dailyTaken: Date?
    }

    private func load() {
        guard let data = try? Data(contentsOf: AppPaths.basalFile),
              let s = try? JSONDecoder.iso.decode(Snapshot.self, from: data) else { return }
        morningTaken = s.morningTaken
        eveningTaken = s.eveningTaken
        dailyTaken = s.dailyTaken
    }

    private func save() {
        let s = Snapshot(morningTaken: morningTaken, eveningTaken: eveningTaken, dailyTaken: dailyTaken)
        guard let data = try? JSONEncoder.iso.encode(s) else { return }
        try? data.write(to: AppPaths.basalFile)
    }
}
