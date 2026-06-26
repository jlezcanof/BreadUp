//
//  BreadUpMigrationPlan.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 8/4/26.
//

import Foundation
import SwiftData

typealias BreadUpIngredients = BreadUpSchemaV3.Ingredients
typealias BreadUpCalculate   = BreadUpSchemaV3.CalculateBread
typealias BreadUpStepRecipe  = BreadUpSchemaV3.StepRecipe

enum BreadUpMigrationPlan: SchemaMigrationPlan {

  static var schemas: [any VersionedSchema.Type] {
    [BreadUpSchemaV1.self, BreadUpSchemaV2.self, BreadUpSchemaV3.self]
  }

  static var stages: [MigrationStage] {
    [
      //            .lightweight(fromVersion: BreadUpSchemaV1.self, toVersion: BreadUpSchemaV2.self)
      migrationV1toV2,
      // pending migrate to v2
      migrationV2toV3,
    ]
  }

  // V2 -> V3: solo añade la entidad StepRecipe y la relación 1-N (parte vacía),
  // por lo que no requiere transformación de datos: migración ligera.
  static let migrationV2toV3 = MigrationStage.lightweight(
    fromVersion: BreadUpSchemaV2.self,
    toVersion: BreadUpSchemaV3.self
  )

  static let migrationV1toV2 = MigrationStage.custom(
    fromVersion: BreadUpSchemaV1.self, toVersion: BreadUpSchemaV2.self
  ) { modelContext in

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

enum FlourType: String, CaseIterable, Identifiable, Codable {
  case wheat = "Trigo"//Harina de trigo
  case wholewheat = "Trigo integral"//Harina de trigo integral
  case rye = "Centeno"//Harina de Centeno
  case spelt = "Espelta"//Harina de espelta
  case corn = "Maíz"//Harina de maz

  var id: Self { self }
}

extension FlourType {

  var displayName: String {
    switch self {
    case .wheat:
      return "Harina de trigo"
    case .wholewheat:
      return "Harina de trigo integral"
    case .rye:
      return "Harina de Centeno"
    case .spelt:
      return "Harina de espelta"
    case .corn:
      return "Harina de maíz"
    }
  }
    
  var name: String {
    switch self {
    case .wheat:
      return "wheat"
    case .wholewheat:
      return "wholewheat"
    case .rye:
      return "rye"
    case .spelt:
      return "spelt"
    case .corn:
      return "corn"
    }
  }
}

extension BreadUpSchemaV3.Ingredients {
  @MainActor static let example = BreadUpSchemaV3.Ingredients(
    id: UUID(),
    water: 250,
    flourTypeString: "corn",
    flourQuantity: 300,
    // saltQuantity: 5,
    yeast: 150,
    createdAt: Date())
}
