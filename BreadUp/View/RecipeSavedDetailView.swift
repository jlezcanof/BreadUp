//
//  RecipeSavedDetailView.swift
//  BreadUp
//
//  Created by Yomismista on 8/4/26.
//

import SwiftUI

struct RecipeSavedDetailView: View {
    
    let recipe: BreadUpIngredients

    var body: some View {
        Form {
            Section("Harina") {
                LabeledContent("Tipo", value: recipe.flourType.displayName)
                LabeledContent("Cantidad", value: "\(recipe.flourQuantity) ml")
            }

            Section("Levadura") {
                LabeledContent("Cantidad", value: "\(recipe.yeast) gramos")
            }

            Section("Agua") {
                LabeledContent("Cantidad", value: "\(recipe.water) ml")
            }
            if let result = recipe.calculateBread, let recipe = result.recipe {
                Section("Receta") {// Resultado
                    LabeledContent("Receta", value: "\(recipe)")
                }
            }
        }
        .navigationTitle(recipe.flourType.displayName)
    }
}

#Preview {
    RecipeSavedDetailView(recipe: BreadUpIngredients.example)
}
