//
//  BreadUpMigrationPlan.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 8/4/26.
//

import Foundation
import SwiftData

enum BreadUpMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [BreadUpSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        [
//            .lightweight(fromVersion: BreadUpSchemaV1.self, toVersion: BreadUpSchemaV2.self)
        ]
    }
}

typealias BreadUpIngredients         = BreadUpSchemaV1.Ingredients
typealias BreadUpCalculate           = BreadUpSchemaV1.CalculateBread


enum TypeFlour: String, Identifiable, Codable, CaseIterable {
    
   case wheat
   case wholewheat
   case rye
   case spelt
   case corn
    
    var id: Self {self}
}

enum FlourType: String, CaseIterable, Identifiable, Codable {
    case wheat = "Harina de trigo"
    case wholewheat = "Harina de trigo integral"
    case rye = "Harina de Centeno"
    case spelt = "Harina de espelta"
    case corn = "Harina de maíz"

    var id: Self { self }
}

extension FlourType { // BreadUpSchemaV1.TypeFlour
    
    var displayName: String {
        switch self {
        case .wheat:     "Harina de trigo"
        case .wholewheat: "Harina de trigo integral"
        case .rye:       "Harina de Centeno"
        case .spelt:     "Harina de espelta"
        case .corn:      "Harina de maíz"
        }
    }
}

extension FlourType {
    var toSchemaType: FlourType { // BreadUpSchemaV1.TypeFlour
        switch self {
        case .wheat:      .wheat
        case .wholewheat: .wholewheat
        case .rye:        .rye
        case .spelt:      .spelt
        case .corn:       .corn
        }
    }
}
