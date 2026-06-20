//
//  StepRow.swift
//  BreadUp
//

import FoundationModels
import SwiftUI

/// Fila de un paso durante la generación en streaming: muestra el `StepCard`
/// solo cuando el paso parcial ya tiene título y descripción.
struct StepRow: View {
  let step: RecipeStep.PartiallyGenerated
  let number: Int

  var body: some View {
    if let titulo = step.titulo, let descripcion = step.descripcion {
      StepCard(
        number: number,
        titulo: titulo,
        descripcion: descripcion
      )
    }
  }
}
