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
    @Environment(BreadCalculatorVM.self) private var vm
    @Query private var recipes: [BreadUpIngredients]

    var body: some View {
        List {
            ForEach(recipes) { recipe in
                NavigationLink(value: Route.saved(recipe)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(recipe.calculateBread?.recipe ?? "Receta sin título")
                            .font(.headline)
                        HStack {
                            Label("\(recipe.water) ml", systemImage: "drop.fill")
                                .foregroundStyle(Color("BreadWater"))
                            Spacer()
                            Label("\(recipe.flourQuantity) g", systemImage: "leaf.fill")
                                .foregroundStyle(Color("BreadFlour"))
                            Spacer()
                            Label("\(recipe.yeast) g", systemImage: "bubbles.and.sparkles.fill")
                                .foregroundStyle(Color("BreadYeast"))
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        if let created = recipe.created {
                            HStack {
                                Image(systemName: "calendar.circle")
                                    .foregroundStyle(Color("BreadDate"))
                                Text(created, format: .dateTime.day().month().year())
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    .accessibilityElement(children: .combine)
                }
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
        .navigationTitle("Mis Recetas de pan")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    vm.path.append(.detail)
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Nueva receta")
            }
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
        .environment(BreadCalculatorVM())
}
