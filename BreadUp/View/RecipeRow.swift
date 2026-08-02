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
      recipe.calculateBread?.recipe ?? "Receta sin título"
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(alignment: .firstTextBaseline, spacing: 6) {
        Text(titleRecipe)
          .font(.headline)
          .lineLimit(2)
          .allowsTightening(true)
          .accessibilityLabel("Título de la receta")
          .accessibilityValue(titleRecipe)
          .accessibilitySortPriority(1)

        if recipe.isFavorite {
          Image(systemName: "star.fill")
            .foregroundStyle(.yellow)
            .accessibilityLabel("Receta favorita")
            .accessibilitySortPriority(2)
        }
      }
        Text("Harina de \(recipe.flourType.rawValue)")//recipe.flourType.displayName
          .font(.headline)
          .lineLimit(1, reservesSpace:true)
          .accessibilityValue("Harina de \(recipe.flourType.rawValue)")//recipe.flourType.displayName
          .accessibilitySortPriority(3)
      HStack {
        Label("\(recipe.water) ml", systemImage: "drop.fill")
          .foregroundStyle(Color("BreadWater"))
          .accessibilityLabel("Agua, \(recipe.water) mililitros")
          .accessibilitySortPriority(4)
        Spacer()
        Label("\(recipe.flourQuantity) g", systemImage: "leaf.fill")
          .foregroundStyle(Color("BreadFlour"))
          .accessibilityLabel("Harina, \(recipe.flourQuantity) gramos")
          .accessibilitySortPriority(5)
        Spacer()
        Label("\(recipe.yeast) g", systemImage: "bubbles.and.sparkles.fill")
          .foregroundStyle(Color("BreadYeast"))
          .accessibilityLabel("Levadura, \(recipe.yeast) gramos")
          .accessibilitySortPriority(6)
      }
      .font(.subheadline)
      .foregroundStyle(.secondary)
      if let created = recipe.created {
        HStack {
          Image(systemName: "calendar.circle")
            .foregroundStyle(Color(.breadDate)) //"BreadDate"
            .accessibilityHidden(true)
            .accessibilityValue("Fecha de la receta")
          Text(created, format: .dateTime.day().month().year())
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .combine)
        .accessibilitySortPriority(7)
      }
    }
    .padding(.vertical, 4)
    .accessibilityElement(children: .combine)
  }
}

#Preview {
  List {
    RecipeRow(
      recipe: BreadUpIngredients(
        id: UUID(), water: 250, flourType: .wheat, flourQuantity: 300,
        yeast: 6, createdAt: .now, isFavorite: true))
    RecipeRow(
      recipe: BreadUpIngredients(
        id: UUID(), water: 220, flourType: .rye, flourQuantity: 280,
        yeast: 8, createdAt: .now))
  }
}
