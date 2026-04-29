import Foundation

enum BasalTrackingMode: String, Codable, CaseIterable {
    case amPm
    case oncePerDay
    case off
}

struct AppSettings: Codable, Equatable {
    var peakActivityMinutes: Double
    var actionDurationMinutes: Double
    var basalTracking: BasalTrackingMode
    var defaultDoseAmounts: [Double]

    static let `default` = AppSettings(
        peakActivityMinutes: 75,
        actionDurationMinutes: 360,
        basalTracking: .amPm,
        defaultDoseAmounts: [0.5, 1.0, 1.5, 2.0]
    )

    var insulinModel: InsulinModel {
        InsulinModel(
            peakActivityTime: peakActivityMinutes * 60,
            actionDuration: actionDurationMinutes * 60
        )
    }
}
