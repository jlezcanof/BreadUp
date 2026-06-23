//
//  RecipeRow.swift
//  BreadUp
//

import SwiftUI

/// Fila de una receta en la lista: título, tipo de harina + ingredientes
/// (con color de marca) y fecha. Se combina como un único elemento para VoiceOver.
struct RecipeRow: View {
  let recipe: BreadUpIngredients
    
    private var titleRecipe: String {
        var title = recipe.calculateBread?.recipe ?? "Receta sin título"
        title.append(" - ")
        title.append(recipe.flourType.displayName)
        return title
    }

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(titleRecipe)
        .font(.headline)
      HStack {
        Label("\(recipe.water) ml", systemImage: "drop.fill")
          .foregroundStyle(Color("BreadWater"))
          .accessibilityLabel("Agua, \(recipe.water) mililitros")
        Spacer()
        Label("\(recipe.flourQuantity) g", systemImage: "leaf.fill")
          .foregroundStyle(Color("BreadFlour"))
          .accessibilityLabel("Harina, \(recipe.flourQuantity) gramos")
        Spacer()
        Label("\(recipe.yeast) g", systemImage: "bubbles.and.sparkles.fill")
          .foregroundStyle(Color("BreadYeast"))
          .accessibilityLabel("Levadura, \(recipe.yeast) gramos")
      }
      .font(.subheadline)
      .foregroundStyle(.secondary)
      if let created = recipe.created {
        HStack {
          Image(systemName: "calendar.circle")
            .foregroundStyle(Color("BreadDate"))
            .accessibilityHidden(true)
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
