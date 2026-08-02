//
//  FavoriteRecipesView.swift
//  BreadUp
//

import SwiftData
import SwiftUI

/// Lista simple de recetas favoritas, sin buscador ni hoja de filtros.
struct FavoriteRecipesView: View {
  @Query(
    filter: #Predicate<BreadUpIngredients> { $0.isFavorite },
    sort: \BreadUpIngredients.created,
    order: .reverse
  )
  private var favoriteRecipes: [BreadUpIngredients]

  var body: some View {
    List {
      ForEach(favoriteRecipes) { recipe in
        NavigationLink(value: Route.saved(recipe)) {
          RecipeRow(recipe: recipe)
        }
      }
    }
    .overlay {
      if favoriteRecipes.isEmpty {
        ContentUnavailableView(
          "Sin favoritos",
          systemImage: "star",
          description: Text(
            "Desliza una receta hacia la derecha en Mis recetas para marcarla como favorita"
          )
        )
      }
    }
    .navigationTitle("Favoritos")
    .navigationBarTitleDisplayMode(.large)
  }
}

#Preview {
  NavigationStack {
    FavoriteRecipesView()
  }
  .environment(BreadCalculatorVM(recipeIndexer: SpotlightRecipeIndexer()))
}
