//
//  ContentView.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 25/3/26.
//

import SwiftUI
import SwiftData

/// Rutas de navegación de la app.
///
/// - `.generate` solo se alcanza dentro del `NavigationStack` interno del
///   sheet de creación de recetas (`CreateRecipeFlowView`), apilado sobre
///   `BreadCalculatorVM.path`.
/// - `.saved` se usa en las pilas de `push` de ambas pestañas del `TabView`:
///   "Mis recetas" (`recipesPath`) y "Favoritos" (`favoritesPath`), ambas
///   locales a `ContentView`.
enum Route: Hashable {
    case generate                   // Generar la receta con FoundationModels
    case saved(BreadUpIngredients)  // Detalle de una receta ya guardada
}

struct ContentView: View {

    @State private var recipesPath: [Route] = []
    @State private var favoritesPath: [Route] = []

    var body: some View {
        TabView {
            Tab("Mis recetas", systemImage: "list.bullet") {
                NavigationStack(path: $recipesPath) {
                    RecipeListView()
                        .navigationDestination(for: Route.self) { route in
                            routeDestination(route)
                        }
                }
            }
            Tab("Favoritos", systemImage: "star.fill") {
                NavigationStack(path: $favoritesPath) {
                    FavoriteRecipesView()
                        .navigationDestination(for: Route.self) { route in
                            routeDestination(route)
                        }
                }
            }
        }
    }

    @ViewBuilder
    private func routeDestination(_ route: Route) -> some View {
        switch route {
            case .generate:
                // No debería alcanzarse desde aquí: ni `recipesPath` ni
                // `favoritesPath` reciben nunca `.generate` (solo `vm.path`,
                // consumido por `CreateRecipeFlowView`). Se mantiene por
                // exhaustividad de `Route`, compartido con ese otro flujo.
                GenerateBreadRecipeView()
            case .saved(let recipe):
                RecipeSavedDetailView(recipe: recipe)
        }
    }
}

#Preview {
    ContentView()
        .environment(BreadCalculatorVM(recipeIndexer: SpotlightRecipeIndexer()))
}
