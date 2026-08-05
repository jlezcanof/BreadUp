//
//  CreateRecipeFlowView.swift
//  BreadUp
//

import SwiftUI

/// Flujo de "crear + generar receta" presentado como sheet modal desde el
/// botón "+" de `RecipeListView`, para ocultar la tab bar mientras dura esta
/// tarea multi-paso (HIG "Modality").
///
/// Envuelve su propio `NavigationStack`, empujando sobre
/// `BreadCalculatorVM.path` (el mismo `path` que ya usan
/// `navigateToGenerateView()`/`backToRecipeList()`, sin tocar el VM).
/// `RecipeDetailView` es la RAÍZ de esta pila — ya no un caso empujado—, por
/// lo que su botón "Cancelar" cierra el sheet entero en vez de hacer un pop.
///
/// El cierre tras un guardado con éxito no puede delegarse en el `dismiss()`
/// propio de `GenerateBreadRecipeView`: una vista empujada en un
/// `NavigationStack` siempre tiene "algo que hacer pop" (a sí misma), así que
/// su `dismiss()` nunca escala a cerrar un sheet ancestro. Por eso observamos
/// `vm.didSaveRecipe` aquí, en la raíz de la jerarquía del sheet, y llamamos
/// a nuestro propio `dismiss()` — el único que SwiftUI resuelve como "cerrar
/// el sheet" al no haber nada que hacer pop en esta raíz.
struct CreateRecipeFlowView: View {

    @Environment(BreadCalculatorVM.self) private var vm
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var vm = vm
        NavigationStack(path: $vm.path) {
            RecipeDetailView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                        case .generate:
                            GenerateBreadRecipeView()
                        case .saved:
                            // No debería alcanzarse: `vm.path` solo recibe
                            // `.generate` (vía `navigateToGenerateView()`).
                            // `.saved` pertenece a las pilas de "Mis recetas"
                            // y "Favoritos" (`ContentView`), ajenas a este flujo.
                            EmptyView()
                    }
                }
        }
        .onChange(of: vm.didSaveRecipe) { _, saved in
            guard saved else { return }
            vm.didSaveRecipe = false
            dismiss()
        }
    }
}

#Preview {
    CreateRecipeFlowView()
        .environment(BreadCalculatorVM(recipeIndexer: SpotlightRecipeIndexer()))
}
