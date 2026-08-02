//
//  ContentView.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 25/3/26.
//

import SwiftUI
import SwiftData

/// Rutas de navegación de la app. Cada pestaña del `TabView` mantiene su
/// propia pila: la de "Mis recetas" usa `BreadCalculatorVM.path` (compartido
/// con el flujo de creación de recetas), la de "Favoritos" usa un `path`
/// local a `ContentView`.
enum Route: Hashable {
    case detail                     // Configurar/crear una nueva receta
    case generate                   // Generar la receta con FoundationModels
    case saved(BreadUpIngredients)  // Detalle de una receta ya guardada
}

struct ContentView: View {

    @Environment(BreadCalculatorVM.self) private var vm
    @State private var favoritesPath: [Route] = []

    var body: some View {
        @Bindable var vm = vm
        TabView {
            Tab("Mis recetas", systemImage: "list.bullet") {
                NavigationStack(path: $vm.path) {
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
            case .detail:
                RecipeDetailView()
            case .generate:
                GenerateBreadRecipeView()
            case .saved(let recipe):
                RecipeSavedDetailView(recipe: recipe)
        }
    }
}

#Preview {
    ContentView()
        .environment(BreadCalculatorVM())
}
