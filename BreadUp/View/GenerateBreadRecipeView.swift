//
//  GenerateBreadRecipeView.swift
//  BreadUp
//

import FoundationModels
import SwiftData
import SwiftUI

struct GenerateBreadRecipeView: View {

  @Environment(BreadCalculatorVM.self) private var vm

  // provisional, deberiamos meterlo directamente en el VM
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @State private var showDatePicker = false
  @State private var showSaveDialog = false

  /// Al terminar la generación, lleva el foco de VoiceOver al título del
  /// resultado para anunciar que la receta está lista.
  @AccessibilityFocusState private var recipeTitleFocused: Bool

  private static let bottomID = "recipeBottomAnchor"

  var body: some View {
    @Bindable var vm = vm
    return ScrollViewReader { proxy in
      ScrollView {
        VStack(spacing: 24) {
          if let breadRecipe = vm.recipeBreadSequence,
            let titleBreadRecipe = breadRecipe.content.title,
            let steps = breadRecipe.content.pasos
          {
            summaryHeader(title: titleBreadRecipe)

            if !steps.isEmpty {
              VStack(alignment: .leading, spacing: 16) {
                sectionTitle("Elaboración", systemImage: "list.number")
                LazyVStack(spacing: 16) {
                  ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    StepRow(step: step, number: index + 1)
                  }
                }
              }
            }
          }

          if vm.receivedTotalInformationAboutRecipe {
            actionsBar
          }

          // Ancla invisible al final del contenido: el auto-scroll apunta aquí.
          Color.clear
            .frame(height: 1)
            .id(Self.bottomID)
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
      }
      .background(Color(.systemGroupedBackground))
      // Separa el contenido del borde inferior del scroll (incluida la
      // home indicator), de modo que el auto-scroll no pegue el último
      // elemento — la fila de acciones — al fondo del dispositivo.
      .contentMargins(.bottom, 28, for: .scrollContent)
      // Sigue al último paso mientras se va generando (cada token cambia
      // la descripción del último paso), al aparecer un paso nuevo (count)
      // y al completarse la receta.
      .onChange(of: vm.recipeBreadSequence?.content.pasos?.last?.descripcion) {
        scrollToBottom(proxy)
      }
      .onChange(of: vm.recipeBreadSequence?.content.pasos?.count) {
        scrollToBottom(proxy)
      }
      .onChange(of: vm.receivedTotalInformationAboutRecipe) { _, done in
        scrollToBottom(proxy)
        if done { recipeTitleFocused = true }
      }
      // Al desplegar el calendario, baja para que quede a la vista.
      // Se retrasa el scroll para dar tiempo a que el calendario se
      // inserte y mida; si no, el scroll se queda corto.
      .onChange(of: showDatePicker) { _, isShowing in
        guard isShowing else { return }
        Task {
          try? await Task.sleep(for: .milliseconds(300))
          withAnimation(.easeInOut) {
            proxy.scrollTo(Self.bottomID, anchor: .bottom)
          }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .loadingOverlay(vm.isLoading, message: "Generando receta…")
    .navigationTitle("Nueva receta")
    .navigationBarTitleDisplayMode(.inline)
    .alert("No se pudo generar la receta", isPresented: $vm.hasGenerationError) {
      Button("Reintentar") {
        vm.hasGenerationError = false
        Task { await vm.retryGeneration() }
      }
      Button("Cerrar", role: .cancel) {
        vm.hasGenerationError = false
        dismiss()
      }
    } message: {
      Text(vm.alert)
    }
    .alert("Guardar receta", isPresented: $showSaveDialog) {
      Button("Cancelar", role: .cancel) {}
      Button("Guardar") {
        vm.save(context: modelContext)
        vm.backToRecipeList()
      }
    } message: {
      Text("¿Quieres guardar esta receta en tu recetario?")
    }
  }

  // MARK: - Cabecera resumen

  /// Tarjeta de cabecera: título de la receta + chips con los ingredientes
  /// elegidos, usando los colores de marca. Conecta el resultado con lo pedido.
  private func summaryHeader(title: String) -> some View {
    VStack(alignment: .leading, spacing: 14) {
      Text(title)
        .font(.title2.bold())
        .foregroundStyle(.primary)
        .accessibilityAddTraits(.isHeader)
        .accessibilityFocused($recipeTitleFocused)

      HStack(spacing: 10) {
        ingredientChip(
          icon: "leaf.fill", tint: Color("BreadFlour"),
          value: "\(vm.flourQuantity) g",
          label: "Harina, \(vm.flourQuantity) gramos")
        ingredientChip(
          icon: "drop.fill", tint: Color("BreadWater"),
          value: "\(vm.water) ml",
          label: "Agua, \(vm.water) mililitros")
        ingredientChip(
          icon: "bubbles.and.sparkles.fill", tint: Color("BreadYeast"),
          value: "\(vm.yeast) g",
          label: "Levadura, \(vm.yeast) gramos")
        Spacer(minLength: 0)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(18)
    .background {
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(Color(.secondarySystemGroupedBackground))
    }
  }

  private func ingredientChip(
    icon: String, tint: Color, value: String, label: String
  ) -> some View {
    HStack(spacing: 6) {
      Image(systemName: icon)
        .font(.caption.weight(.semibold))
        .foregroundStyle(tint)
      Text(value)
        .font(.subheadline.weight(.medium))
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 7)
    .background { Capsule().fill(tint.opacity(0.12)) }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(label)
  }

  // MARK: - Barra de acciones

  /// Fila de acciones que aparece al completarse la receta: elegir fecha de
  /// elaboración y guardar. Los botones usan los estilos Liquid Glass del
  /// sistema por flotar sobre el contenido.
  private var actionsBar: some View {
    @Bindable var vm = vm
    return VStack(spacing: 16) {
      HStack(spacing: 12) {
        Button {
          withAnimation { showDatePicker.toggle() }
        } label: {
          HStack(spacing: 8) {
            Image(systemName: "calendar")
            Text(vm.selectedDate, format: .dateTime.day().month().year())
          }
          .font(.subheadline)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.capsule)
        .accessibilityLabel("Fecha de elaboración")
        .accessibilityValue(vm.selectedDate.formatted(.dateTime.day().month().year()))
        .accessibilityHint("Cambia la fecha de la receta")

        Spacer(minLength: 12)

        Button {
          showSaveDialog.toggle()
        } label: {
          Label("Guardar", systemImage: "tray.and.arrow.down")
            .font(.headline)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
      }

      if showDatePicker {
        DatePicker(
          "Fecha de elaboración",
          selection: $vm.selectedDate,
          displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .onChange(of: vm.selectedDate) {
          withAnimation { showDatePicker = false }
        }
        .padding(.horizontal, 8)
        .background {
          RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(.secondarySystemGroupedBackground))
        }
      }
    }
  }

  // MARK: - Helpers

  private func sectionTitle(_ text: String, systemImage: String) -> some View {
    Label(text, systemImage: systemImage)
      .font(.title2.bold())
      .padding(.leading, 4)
      .accessibilityAddTraits(.isHeader)
  }

  private func scrollToBottom(_ proxy: ScrollViewProxy) {
    proxy.scrollTo(Self.bottomID, anchor: .bottom)
  }

  private struct StepRow: View {

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

}

#Preview {
  GenerateBreadRecipeView()
    .environment(BreadCalculatorVM())
}
