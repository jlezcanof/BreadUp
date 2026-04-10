//
//  BreadUpSchemaV1.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 8/4/26.
//

import Foundation
import SwiftData

enum BreadUpSchemaV1: VersionedSchema {
    
    static var versionIdentifier: Schema.Version {
        Schema.Version(1, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        [Ingredients.self, CalculateBread.self]
    }
    
     enum TypeFlour: String, Identifiable, Codable, CaseIterable {
         
        case wheat
        case wholewheat
        case rye
        case spelt
        case corn
         
         var id: Self {self}
    }
    
    @Model
    final class Ingredients {
        @Attribute(.unique) var id: UUID
        var water: Int
        var flourType: FlourType//TypeFlour
        var flourQuantity: Int
        var yeast: Int

        @Relationship(deleteRule: .cascade, inverse: \CalculateBread.ingredients)
        var calculateBread: CalculateBread?

        init(
            id: UUID,
            water: Int,
            flourType: FlourType,//TypeFlour
            flourQuantity: Int,
            yeast: Int
        ) {
            self.id = id
            self.water = water
            self.flourType = flourType
            self.flourQuantity = flourQuantity
            self.yeast = yeast
        }
    }

    @Model
    final class CalculateBread {
        @Attribute(.unique) var id: UUID
        var time: Int
        var temperature: Int

        var ingredients: Ingredients?

        init(id: UUID, time: Int, temperature: Int) {
            self.id = id
            self.time = time
            self.temperature = temperature
        }
    }
    
}

//extension BreadUpSchemaV1.TypeFlour {
//    
//    var displayName: String {
//        switch self {
//        case .wheat:     "Harina de trigo"
//        case .wholewheat: "Harina de trigo integral"
//        case .rye:       "Harina de Centeno"
//        case .spelt:     "Harina de espelta"
//        case .corn:      "Harina de maíz"
//        }
//    }
//}

extension BreadUpSchemaV1.Ingredients  {
    @MainActor static let example = BreadUpIngredients(id: UUID(),
                                            water: 250,
                                            flourType: .corn,
                                            flourQuantity: 300,
                                            yeast: 150)
}
