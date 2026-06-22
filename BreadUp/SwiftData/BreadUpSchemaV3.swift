//
//  BreadUpSchemaV3.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 8/4/26.
//
import Foundation
import SwiftData

enum BreadUpSchemaV3: VersionedSchema {
  static var versionIdentifier: Schema.Version {
    Schema.Version(3, 0, 0)
  }

  static var models: [any PersistentModel.Type] {
    [Ingredients.self, CalculateBread.self, StepRecipe.self]
  }

  @Model
  final class Ingredients {
    @Attribute(.unique) var id: UUID
    var water: Int
    var flourType: FlourType
    var flourQuantity: Int
    //        var saltQuantity: Int
    var yeast: Int
    var created: Date?

    @Relationship(deleteRule: .cascade, inverse: \CalculateBread.ingredients)
    var calculateBread: CalculateBread?

    init(
      id: UUID,
      water: Int,
      flourType: FlourType = .wheat,
      flourQuantity: Int,
      //            saltQuantity: Int,
      yeast: Int,
      createdAt: Date? = nil
    ) {
      self.id = id
      self.water = water
      self.flourType = flourType
      self.flourQuantity = flourQuantity
      //            self.saltQuantity  = saltQuantity
      self.yeast = yeast
      self.created = createdAt
    }
  }

  @Model
  final class CalculateBread {
    @Attribute(.unique) var id: UUID

    var ingredients: Ingredients?

    var recipe: String?

    // Relación 1-N: una receta calculada tiene N pasos.
    @Relationship(deleteRule: .cascade, inverse: \StepRecipe.calculateBread)
    var steps: [StepRecipe] = []

    init(  //id: UUID,
      recipe: String?
    ) {
      self.id = UUID()
      self.recipe = recipe
    }
  }

  @Model
  final class StepRecipe {
    @Attribute(.unique) var id: UUID
    var order: Int
    var title: String
    var descripcion: String

    // Lado "uno" de la relación con CalculateBread.
    var calculateBread: CalculateBread?

    init(  //id: UUID,
      order: Int, title: String, descripcion: String
    ) {
      self.id = UUID()
      self.order = order
      self.title = title
      self.descripcion = descripcion
    }
  }
}
