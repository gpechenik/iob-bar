//
//  InsulinModel.swift
//  iob-bar
//
//  Derived from LoopKit's ExponentialInsulinModel.swift
//  https://github.com/LoopKit/LoopKit
//  Copyright LoopKit Authors, licensed under Apache License, Version 2.0
//
//  Modifications: simplified to a self-contained struct without LoopKit's
//  broader InsulinKit / LoopAlgorithm dependencies. The math is unchanged.
//

import Foundation

/// Exponential insulin pharmacokinetic model.
///
/// Computes the fraction of an insulin dose that remains active at a given
/// time after delivery. Uses a biexponential curve parameterized by peak
/// activity time and total action duration. This is the model LoopKit
/// adopted in place of the older Walsh bilinear curve.
///
/// At t=0, fractionRemaining is 1.0. At t≥actionDuration, it is 0.0. In
/// between, the curve falls smoothly with a shape determined by peakActivityTime.
struct InsulinModel: Codable, Equatable {
    /// Time at which insulin activity peaks, in seconds since dose.
    let peakActivityTime: TimeInterval

    /// Total duration of insulin action, in seconds since dose.
    let actionDuration: TimeInterval

    /// Humalog / Novolog adult preset (per LoopKit): 75-min peak, 6-hr duration.
    static let humalogAdult = InsulinModel(
        peakActivityTime: 75 * 60,
        actionDuration: 360 * 60
    )

    /// Returns the fraction (0.0–1.0) of a dose still on board at `time`
    /// seconds after delivery.
    func fractionRemaining(at time: TimeInterval) -> Double {
        if time <= 0 { return 1 }
        if time >= actionDuration { return 0 }

        let tau = peakActivityTime * (1 - peakActivityTime / actionDuration)
                  / (1 - 2 * peakActivityTime / actionDuration)
        let a = 2 * tau / actionDuration
        let S = 1 / (1 - a + (1 + a) * exp(-actionDuration / tau))

        return 1 - S * (1 - a) * (
            (pow(time, 2) / (tau * actionDuration * (1 - a)) - time / tau - 1)
            * exp(-time / tau) + 1
        )
    }
}
