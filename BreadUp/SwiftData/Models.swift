//
//  Models.swift
//  BreadUp
//
//  Created by Yomismista on 8/4/26.
//

import Foundation
import SwiftData

@Model
final class Ingredients {
    var water: Int
    var flourType: FlourType
    var flourQuantity: Int
    var yeast: Int

    @Relationship(deleteRule: .cascade, inverse: \CalculateBread.ingredients)
    var calculateBread: CalculateBread?

    init(
        water: Int,
        flourType: FlourType,
        flourQuantity: Int,
        yeast: Int
    ) {
        self.water = water
        self.flourType = flourType
        self.flourQuantity = flourQuantity
        self.yeast = yeast
    }
}

@Model
final class CalculateBread {
    var time: Int
    var temperature: Int

    var ingredients: Ingredients?

    init(time: Int, temperature: Int) {
        self.time = time
        self.temperature = temperature
    }
}
