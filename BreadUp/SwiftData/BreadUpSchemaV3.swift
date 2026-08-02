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
    var flourTypeString: String
    var flourQuantity: Int
    //        var saltQuantity: Int
    var yeast: Int
    var created: Date?

    @Relationship(deleteRule: .cascade, inverse: \CalculateBread.ingredients)
    var calculateBread: CalculateBread?

    init(
      id: UUID,
      water: Int,
      flourTypeString: String = "wheat",
      flourQuantity: Int,
      //            saltQuantity: Int,
      yeast: Int,
      createdAt: Date? = nil
    ) {
      self.id = id
      self.water = water
      // Store the canonical flour type identifier in `flourTypeString`.
      self.flourQuantity = flourQuantity
      self.flourTypeString = flourTypeString
      //            self.saltQuantity  = saltQuantity
      self.yeast = yeast
      self.created = createdAt
    }

    // Backwards-compatible computed property to expose the FlourType
    // enum used across the UI. The persistent model stores the compact
    // identifier in `flourTypeString` (e.g. "wheat"). The computed
    // property maps to/from that string so existing call sites that
    // use `flourType` continue to work.
    var flourType: FlourType {
      get {
        FlourType.allCases.first(where: { $0.name == flourTypeString }) ?? .wheat
      }
      set {
        flourTypeString = newValue.name
      }
    }

    // Convenience initializer that matches older call sites that passed
    // a `FlourType` value directly.
    convenience init(
      id: UUID,
      water: Int,
      flourType: FlourType = .wheat,
      flourQuantity: Int,
      yeast: Int,
      createdAt: Date? = nil
    ) {
      self.init(
        id: id,
        water: water,
        flourTypeString: flourType.name,
        flourQuantity: flourQuantity,
        yeast: yeast,
        createdAt: createdAt
      )
    }
      
      var toEntity: RecipeBreadEntity {
          
          var contentSteps = "Pasos de la receta"
          
          self.calculateBread?.steps.sorted {$0.order < $1.order}.forEach { step in
              contentSteps += "\n\n- ** Paso \(step.order)"
              contentSteps += "\n  - Título: \(step.title)"
              contentSteps += "\n  - Descripcion: \(step.descripcion)"
          }
          
          return RecipeBreadEntity(id: self.id.uuidString, title: self.calculateBread?.recipe ?? "title" ,
                            contentSteps: contentSteps, createdAt: created ?? .now)
      }
  }

  @Model
  final class CalculateBread {
    @Attribute(.unique) var id: UUID

    var ingredients: Ingredients?
    var recipe: String

    // Relación 1-N: una receta calculada tiene N pasos.
    @Relationship(deleteRule: .cascade, inverse: \StepRecipe.calculateBread)
    var steps: [StepRecipe] = []

    init(//id: UUID,
      recipe: String
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
