//
//  RecipeListView.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano Fresno on 8/4/26.
//


import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [BreadUpIngredients]
    @State private var showNewRecipe = false

    var body: some View {
        List {
            ForEach(recipes) { recipe in
                VStack(alignment: .leading, spacing: 6) {
 //                   Text(recipe.flourType.displayName)
//                        .font(.headline)
                    HStack {
                        Label("\(recipe.water) ml", systemImage: "drop.fill")
                        Spacer()
                        Label("\(recipe.flourQuantity) ml", systemImage: "leaf.fill")
                        Spacer()
                        Label("\(recipe.yeast) g", systemImage: "microbe.fill")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    if let result = recipe.calculateBread {
                        HStack {
                            Label("\(result.time) min", systemImage: "clock.fill")
                            Spacer()
                            Label("\(result.temperature) °C", systemImage: "thermometer.medium")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                    }
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: deleteRecipes)
        }
        .overlay {
            if recipes.isEmpty {
                ContentUnavailableView(
                    "No hay recetas",
                    systemImage: "cooktop",
                    description: Text("Pulsa + para crear tu primera receta")
                )
            }
        }
        .navigationTitle("Mis Recetas")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showNewRecipe = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationDestination(isPresented: $showNewRecipe) {
            RecipeDetailView()
        }
    }

    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(recipes[index])
            }
        }
    }
}

#Preview {
    RecipeListView()
}
