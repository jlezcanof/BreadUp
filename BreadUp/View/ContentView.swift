//
//  ContentView.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 25/3/26.
//

import SwiftUI
import SwiftData

/// Rutas de navegación de la app. Toda la pila se gestiona desde un único
/// `NavigationStack` cuyo `path` vive en `BreadCalculatorVM`.
enum Route: Hashable {
    case detail                     // Configurar/crear una nueva receta
    case generate                   // Generar la receta con FoundationModels
    case saved(BreadUpIngredients)  // Detalle de una receta ya guardada
}

struct ContentView: View {

    @Environment(BreadCalculatorVM.self) private var vm

    var body: some View {
        @Bindable var vm = vm
        NavigationStack(path: $vm.path) {
            RecipeListView()
                .navigationDestination(for: Route.self) { route in
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
    }
}

#Preview {
    ContentView()
        .environment(BreadCalculatorVM(recipeIndexer: SpotlightRecipeIndexer()))
}
