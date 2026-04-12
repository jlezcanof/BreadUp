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
        [BreadUpSchemaV1.self, BreadUpSchemaV2.self]
    }
    

    static var stages: [MigrationStage] {
        [
//            .lightweight(fromVersion: BreadUpSchemaV1.self, toVersion: BreadUpSchemaV2.self)
            migrationV1tovV2
        ]
    }
    
        static let migrationV1tovV2 = MigrationStage.custom(fromVersion: BreadUpSchemaV1.self, toVersion: BreadUpSchemaV2.self) { modelContext in
            let descriptor = FetchDescriptor< BreadUpSchemaV1.Ingredients>()
            let oldIngredients = try modelContext.fetch(descriptor)
            for old in oldIngredients {
                identifiersIngredientes.append(old.id)
            }
    
        } didMigrate: { modelContext in
            for identifier in identifiersIngredientes {
                let descriptor = FetchDescriptor< BreadUpSchemaV2.Ingredients>(
                    predicate: #Predicate {$0.id == identifier}
                )
                let localIngredient = try modelContext.fetch(descriptor).first
                if let localIngredient {
                    localIngredient.calculateBread?.recipe = "Hay que guardar algo"
                    modelContext.insert(localIngredient)
                }
            }
    
            if modelContext.hasChanges {
                try modelContext.save()
            }
        }
}

//actor BreadUp {
    var identifiersIngredientes: [UUID] = []
//}

// pending migrate to v2
typealias BreadUpIngredients         = BreadUpSchemaV2.Ingredients// V1
typealias BreadUpCalculate           = BreadUpSchemaV2.CalculateBread // v1


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
//                                            yeast: 150,
//                                            createdAt: Date())
//}

extension BreadUpSchemaV2.Ingredients  {
    @MainActor static let example = BreadUpSchemaV2.Ingredients(id: UUID(),
                                            water: 250,
                                            flourType: .corn,
                                            flourQuantity: 300,
//                                            saltQuantity: 5,
                                            yeast: 150,
                                            createdAt: Date())
}
