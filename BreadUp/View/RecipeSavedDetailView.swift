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
            
            if let created = recipe.created {
                Section("Fecha de elaboración") {
                    HStack {
                            Text(created, format: .dateTime.day().month().year())
                                .foregroundStyle(.secondary)
                    }
                }
            }
            if let result = recipe.calculateBread, let recipe = result.recipe {
                Section("Receta") {
                    LabeledContent("Receta", value: "\(recipe)")
                }
            }
        }
        .navigationTitle(recipe.flourType.displayName)// TODO incluir tb. la fecha
    }
}

#Preview {
    RecipeSavedDetailView(recipe: BreadUpIngredients.example)
}
