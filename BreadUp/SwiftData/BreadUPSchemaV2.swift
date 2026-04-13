//
//  BreadUPSchemaV2.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 8/4/26.
//
import Foundation
import SwiftData

enum BreadUpSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(2, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        [Ingredients.self, CalculateBread.self]
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
            flourType: FlourType,
            flourQuantity: Int,
//            saltQuantity: Int,
            yeast: Int,
            createdAt: Date? = nil
        ) {
            self.id            = id
            self.water         = water
            self.flourType     = flourType
            self.flourQuantity = flourQuantity
//            self.saltQuantity  = saltQuantity
            self.yeast         = yeast
            self.created       = createdAt
        }
    }

    @Model
    final class CalculateBread {
        @Attribute(.unique) var id: UUID
        
        var recipe: String?

        var ingredients: Ingredients?

        init(id: UUID, recipe: String?) {
            self.id = id
            self.recipe = recipe
        }
    }
    
    // TODO a los ingredientes le vamos a añadir la sal..
    
    //y en la receta sólo vamos a guardar el tiempo de cocción y temperatura...y la fecha que se han guardado..
}
