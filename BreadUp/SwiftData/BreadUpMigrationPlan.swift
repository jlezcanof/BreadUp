//
//  BreadUpMigrationPlan.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 8/4/26.
//

import Foundation
import SwiftData

// pending migrate to v2
typealias BreadUpIngredients         = BreadUpSchemaV3.Ingredients
typealias BreadUpCalculate           = BreadUpSchemaV3.CalculateBread
typealias BreadUpStepRecipe          = BreadUpSchemaV3.StepRecipe

//actor BreadUpSchema {
//    
//}
//
//@BreadUpSchema
//var identifierIngredients : [String] = []

enum BreadUpMigrationPlan: SchemaMigrationPlan {
        
    static var schemas: [any VersionedSchema.Type] {
        [BreadUpSchemaV1.self, BreadUpSchemaV2.self, BreadUpSchemaV3.self]
    }
    
    static var stages: [MigrationStage] {
        [
//            .lightweight(fromVersion: BreadUpSchemaV1.self, toVersion: BreadUpSchemaV2.self)
            migrationV1toV2,
            migrationV2toV3
        ]
    }
    
        // V2 -> V3: solo añade la entidad StepRecipe y la relación 1-N (parte vacía),
        // por lo que no requiere transformación de datos: migración ligera.
        static let migrationV2toV3 = MigrationStage.lightweight(
            fromVersion: BreadUpSchemaV2.self,
            toVersion: BreadUpSchemaV3.self
        )
    
        static let migrationV1toV2 = MigrationStage.custom(fromVersion: BreadUpSchemaV1.self, toVersion: BreadUpSchemaV2.self) { modelContext in
            
//            let descriptor = FetchDescriptor<BreadUpSchemaV1.Ingredients>()
//            let ingredients = try modelContext.fetch(descriptor)
//            
//            for ingredient in ingredients {
//                identifierIngredients.append(ingredient.id.uuidString)
//            }
        } didMigrate: { modelContext in
            let descriptor = FetchDescriptor<BreadUpSchemaV2.Ingredients>()
            let ingredients = try modelContext.fetch(descriptor)
            
            for ingredient in ingredients {
                ingredient.created = .now
                modelContext.insert(ingredient)
            }
            if modelContext.hasChanges {
                try modelContext.save()
            }
        }
}

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

extension FlourType {
    
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
    var toSchemaType: FlourType { 
        switch self {
        case .wheat:      .wheat
        case .wholewheat: .wholewheat
        case .rye:        .rye
        case .spelt:      .spelt
        case .corn:       .corn
        }
    }
}

// BreadUpIngredients
//extension BreadUpSchemaV1.Ingredients  {
//
//    @MainActor static let example = BreadUpIngredients(id: UUID(),
//                                            water: 250,
//                                            flourType: .corn,
//                                            flourQuantity: 300,
//                                            yeast: 150)
//}

extension BreadUpSchemaV3.Ingredients  {
    @MainActor static let example = BreadUpSchemaV3.Ingredients(id: UUID(),
                                            water: 250,
                                            flourType: .corn,
                                            flourQuantity: 300,
//                                            saltQuantity: 5,
                                            yeast: 150,
                                            createdAt: Date())
}
