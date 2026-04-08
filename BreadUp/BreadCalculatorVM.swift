//
//  BreadCalculatorViewModel.swift
//  BreadUp
//

import Foundation

@MainActor
@Observable
final class BreadCalculatorVM {
    var water: Int = 250
    var flourType: FlourType = .wheat
    var flourQuantity: Int = 250
    var yeast: Int = 10

    var time: Int = 0
    var temperature: Int = 0

    func calculate() {
        print("vm.calculate")
        let hydration = Double(water) / Double(flourQuantity)

        let flourFactor: Double = switch flourType {
        case .wheat:      1.0
        case .wholeWheat:  1.15
        case .rye:         1.2
        case .spelt:       1.1
        case .corn:        1.25
        }

        let baseTime = 60.0 - (Double(yeast) * 0.8)
        let adjustedTime = baseTime * flourFactor * (1 + (hydration - 0.6) * 0.3)
        time = max(25, Int(adjustedTime.rounded()))
        print("time is \(time)")

        let baseTemp: Double = switch flourType {
        case .wheat:      200
        case .wholeWheat:  190
        case .rye:         195
        case .spelt:       185
        case .corn:        210
        }

        let tempAdjustment = (hydration - 0.6) * 15
        temperature = Int((baseTemp - tempAdjustment).rounded())
    }
}
