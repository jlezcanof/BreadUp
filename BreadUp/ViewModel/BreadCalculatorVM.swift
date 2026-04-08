//
//  BreadCalculatorViewModel.swift
//  BreadUp
//

import Foundation
import SwiftData

//@MainActor
@Observable
final class BreadCalculatorVM {
    var water: Int = 250
    var flourType: FlourType = .wheat
    var flourQuantity: Int = 250
    var yeast: Int = 10

    var time: Int = 0
    var temperature: Int = 0

    // TODO pendiente de calcular
    func calculate() {
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
    
    func resetResult() {
        time = 0
        temperature = 0
    }
    
    func save(context: ModelContext) {
        let ingredients = BreadUpIngredients(id: UUID(),water: water,
                                             flourType: flourType.toSchemaType,
                                             flourQuantity: flourQuantity,
                                             yeast: yeast)
        
        let result = BreadUpCalculate(id: UUID(), time: time,
                                      temperature: temperature)
        
        ingredients.calculateBread = result
        
        context.insert(ingredients)
    }
}
