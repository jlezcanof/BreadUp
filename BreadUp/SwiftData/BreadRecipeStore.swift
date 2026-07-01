//
//  BreadRecipeStore.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano Fresno on 16/06/2026.
//
import Foundation
import SwiftData

struct BreadRecipeStore {

  let modelContext: ModelContext

  func registerRecipeBread(_ recipe: BreadUpIngredients) throws {

    modelContext.insert(recipe)

    if modelContext.hasChanges {
      try modelContext.save()
    }
  }
}
