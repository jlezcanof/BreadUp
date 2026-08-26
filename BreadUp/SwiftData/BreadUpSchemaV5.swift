//
//  BreadUpSchemaV5.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 8/6/26.
//
import Foundation
import SwiftData

enum BreadUpSchemaV5: VersionedSchema {
  static var versionIdentifier: Schema.Version {
    Schema.Version(5, 0, 0)
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
    var yeast: Int
    var created: Date?
    var isFavorite: Bool = false
    var shapeString: String = "hogaza"
    var pieceWeight: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \CalculateBread.ingredients)
    var calculateBread: CalculateBread?

    init(
      id: UUID,
      water: Int,
      flourTypeString: String = "wheat",
      flourQuantity: Int,
      yeast: Int,
      createdAt: Date? = nil,
      isFavorite: Bool = false,
      shapeString: String = "hogaza",
      pieceWeight: Int? = nil
    ) {
      self.id = id
      self.water = water
      self.flourQuantity = flourQuantity
      self.flourTypeString = flourTypeString
      self.yeast = yeast
      self.created = createdAt
      self.isFavorite = isFavorite
      self.shapeString = shapeString
      self.pieceWeight = pieceWeight ?? (flourQuantity + water + yeast)
    }

    var flourType: FlourType {
      get {
        FlourType.allCases.first(where: { $0.name == flourTypeString }) ?? .wheat
      }
      set {
        flourTypeString = newValue.name
      }
    }

    var shape: BreadShape {
      get {
        BreadShape.allCases.first(where: { $0.name == shapeString }) ?? .hogaza
      }
      set {
        shapeString = newValue.name
      }
    }

    convenience init(
      id: UUID,
      water: Int,
      flourType: FlourType = .wheat,
      flourQuantity: Int,
      yeast: Int,
      createdAt: Date? = nil,
      isFavorite: Bool = false,
      shape: BreadShape = .hogaza,
      pieceWeight: Int? = nil
    ) {
      self.init(
        id: id,
        water: water,
        flourTypeString: flourType.name,
        flourQuantity: flourQuantity,
        yeast: yeast,
        createdAt: createdAt,
        isFavorite: isFavorite,
        shapeString: shape.name,
        pieceWeight: pieceWeight
      )
    }

    var toEntity: RecipeBreadEntity {
      var contentSteps = "Pasos de la receta"

      self.calculateBread?.steps.sorted { $0.order < $1.order }.forEach { step in
        contentSteps += "\n\n- ** Paso \(step.order)"
        contentSteps += "\n  - Título: \(step.title)"
        contentSteps += "\n  - Descripcion: \(step.descripcion)"
      }

      return RecipeBreadEntity(
        id: self.id.uuidString, title: self.calculateBread?.recipe ?? "title",
        contentSteps: contentSteps, createdAt: created ?? .now)
    }
  }

  @Model
  final class CalculateBread {
    @Attribute(.unique) var id: UUID
    var ingredients: Ingredients?
    var recipe: String?
    @Relationship(deleteRule: .cascade, inverse: \StepRecipe.calculateBread)
    var steps: [StepRecipe] = []
    init(
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
    var calculateBread: CalculateBread?
    init(
      order: Int, title: String, descripcion: String
    ) {
      self.id = UUID()
      self.order = order
      self.title = title
      self.descripcion = descripcion
    }
  }
}
