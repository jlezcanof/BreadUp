//
//  BreadUpMigrationPlan.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 8/4/26.
//

import Foundation
import SwiftData
import AppIntents

typealias BreadUpIngredients = BreadUpSchemaV5.Ingredients
typealias BreadUpCalculate   = BreadUpSchemaV5.CalculateBread
typealias BreadUpStepRecipe  = BreadUpSchemaV5.StepRecipe

enum BreadUpMigrationPlan: SchemaMigrationPlan {

  static var schemas: [any VersionedSchema.Type] {
    [BreadUpSchemaV1.self, BreadUpSchemaV2.self, BreadUpSchemaV3.self, BreadUpSchemaV4.self, BreadUpSchemaV5.self]
  }

  static var stages: [MigrationStage] {
    [
      //            .lightweight(fromVersion: BreadUpSchemaV1.self, toVersion: BreadUpSchemaV2.self)
      migrationV1toV2,
      // pending migrate to v2
      migrationV2toV3,
      migrationV3toV4,
      migrationV4toV5,
    ]
  }

  // V2 -> V3: solo añade la entidad StepRecipe y la relación 1-N (parte vacía),
  // por lo que no requiere transformación de datos: migración ligera.
  static let migrationV2toV3 = MigrationStage.lightweight(
    fromVersion: BreadUpSchemaV2.self,
    toVersion: BreadUpSchemaV3.self
  )

  // V3 -> V4: solo añade `isFavorite` (Bool) con valor por defecto false,
  // sin nuevas entidades ni relaciones: migración ligera.
  static let migrationV3toV4 = MigrationStage.lightweight(
    fromVersion: BreadUpSchemaV3.self,
    toVersion: BreadUpSchemaV4.self
  )

  // V4 -> V5: añade `shapeString` (forma de la pieza) y `pieceWeight`
  // (peso aproximado) con valores por defecto, sin nuevas entidades ni
  // relaciones: migración ligera.
  static let migrationV4toV5 = MigrationStage.lightweight(
    fromVersion: BreadUpSchemaV4.self,
    toVersion: BreadUpSchemaV5.self
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

enum FlourType: String, CaseIterable, Identifiable, Codable, AppEnum {
  case wheat = "Trigo"//Harina de trigo
  case wholewheat = "Trigo integral"//Harina de trigo integral
  case rye = "Centeno"//Harina de Centeno
  case spelt = "Espelta"//Harina de espelta
  case corn = "Maíz"//Harina de maz

  var id: Self { self }
    
  static let typeDisplayRepresentation: TypeDisplayRepresentation = "Tipo de Harina"
    
  static let caseDisplayRepresentations: [FlourType : DisplayRepresentation] = [
        .wheat: .init(title: "Trigo", image: .init(systemName: "leaf")),
        .wholewheat: .init(title: "Trigo integral", image: .init(systemName: "laurel.leading")),
        .rye: .init(title: "Centeno", image: .init(systemName: "leaf.arrow.circlepath")),
        .spelt: .init(title: "Espelto", image: .init(systemName: "sparkles")),
       .corn: .init(title: "Maíz", image: .init(systemName: "triangle.fill"))
      ]
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

enum BreadShape: String, CaseIterable, Identifiable, Codable {
  case hogaza = "Hogaza"
  case baguette = "Baguette"
  case molde = "Molde"

  var id: Self { self }

  var displayName: String {
    switch self {
    case .hogaza: return "Hogaza"
    case .baguette: return "Baguette"
    case .molde: return "Molde"
    }
  }

  var name: String {
    switch self {
    case .hogaza: return "hogaza"
    case .baguette: return "baguette"
    case .molde: return "molde"
    }
  }
}

extension BreadUpSchemaV5.Ingredients {
  @MainActor static let example = BreadUpSchemaV5.Ingredients(
    id: UUID(),
    water: 250,
    flourTypeString: "corn",
    flourQuantity: 300,
    // saltQuantity: 5,
    yeast: 150,
    createdAt: Date())
}
