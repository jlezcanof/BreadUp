//
//  GenerateBreadRecipeView.swift
//  BreadUp
//

import FoundationModels
import SwiftData
import SwiftUI

struct GenerateBreadRecipeView: View {

  @Environment(BreadCalculatorVM.self) private var vm    
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
            VStack(alignment: .leading, spacing: 8) {
              summaryHeader(title: titleBreadRecipe)
              // Nota de transparencia (principio HIG de Machine Learning):
              // el contenido es generado y puede no ser exacto. Texto neutro,
              // sin marca "Apple Intelligence".
              Text("Las recetas se generan automáticamente en tu dispositivo y pueden variar.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            }

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

          // Ancla invisible al final del contenido: el auto-scroll apunta aquí.
          Color.clear
            .frame(height: 1)
            .id(Self.bottomID)
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
      }
      .background(Color(.systemGroupedBackground))
      // Barra de acciones flotante: al registrarla como barra del sistema,
      // adopta el scroll edge effect (el contenido se difumina al pasar por
      // detrás) y reserva su propio espacio sobre la home indicator.
      .safeAreaBar(edge: .bottom) {
        if vm.receivedTotalInformationAboutRecipe {
          actionsBar
        }
      }
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
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .loadingOverlay(vm.isLoading, message: "Generando receta…")
    .navigationTitle("Nueva receta")
    .navigationBarTitleDisplayMode(.inline)
    // Control del usuario (HIG de Machine Learning): regenerar otra versión.
    // Solo cuando ya hay un resultado; oculta el item entero, no su contenido.
    .toolbar {
      if vm.receivedTotalInformationAboutRecipe {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            Task { await vm.retryGeneration() }
          } label: {
            Image(systemName: "arrow.clockwise")
          }
          .accessibilityLabel("Regenerar receta")
          .accessibilityHint("Genera otra versión con los mismos ingredientes")
        }
      }
    }
    .alert("No se pudo generar la receta", isPresented: $vm.hasGenerationError) {
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
        vm.save()
        vm.backToRecipeList()
      }
    } message: {
      Text("¿Quieres guardar esta receta en tu recetario?")
    }
    .sheet(isPresented: $showDatePicker) {
      datePickerSheet
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
            VStack(alignment: .leading, spacing: 10) {
                // Fila 1: tipo de harina centrado en todo el ancho.
                HStack(spacing: 0) {
                    Spacer()
                    IngredientChip(
                        icon: "tag.fill",
                        tint: Color("BreadFlour"),
                        value: vm.flourType.displayName,
                        label: "Tipo de harina, \(vm.flourType.displayName)"
                    )
                    Spacer()
                }
                // Fila 2: los 3 chips de cantidad distribuidos de lado a lado.
                HStack(spacing: 0) {
                    IngredientChip(
                        icon: "leaf.fill",
                        tint: Color("BreadFlour"),
                        value: "\(vm.flourQuantity) g",
                        label: "Harina, \(vm.flourQuantity) gramos"
                    )
                    Spacer(minLength: 10)
                    IngredientChip(
                        icon: "drop.fill",
                        tint: Color("BreadWater"),
                        value: "\(vm.water) ml",
                        label: "Agua, \(vm.water) mililitros"
                    )
                    Spacer(minLength: 10)
                    IngredientChip(
                        icon: "bubbles.and.sparkles.fill",
                        tint: Color("BreadYeast"),
                        value: "\(vm.yeast) g",
                        label: "Levadura, \(vm.yeast) gramos"
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
    }

    // MARK: - Barra de acciones

  /// Fila de acciones que aparece al completarse la receta: elegir fecha de
  /// elaboración y guardar. Los botones usan los estilos Liquid Glass del
  /// sistema por flotar sobre el contenido.
  private var actionsBar: some View {
    HStack(spacing: 12) {
      Button {
        showDatePicker = true
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
      .tint(Color("HeroTop"))  // acento de marca (mismo del hero guardado)
    }
    .padding(.horizontal)
    .padding(.top, 8)
  }

  /// Hoja con el calendario para elegir la fecha de elaboración. Mantiene la
  /// barra de acciones compacta y da al `DatePicker` su propio espacio.
  private var datePickerSheet: some View {
    @Bindable var vm = vm
    return NavigationStack {
      VStack {
        DatePicker(
          "Fecha de elaboración",
          selection: $vm.selectedDate,
          displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .padding(.horizontal)
        .onChange(of: vm.selectedDate) { showDatePicker = false }
        Spacer()
      }
      .navigationTitle("Fecha de elaboración")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Listo") { showDatePicker = false }
        }
      }
    }
    .presentationDetents([.medium])
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

}

// MARK: - IngredientChip

/// Cápsula compacta que muestra un icono + valor para un ingrediente.
/// Reutilizable en cualquier cabecera de receta.
private struct IngredientChip: View {

  let icon: String
  let tint: Color
  let value: String
  let label: String

  var body: some View {
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
}

#Preview {
  GenerateBreadRecipeView()
    .environment(BreadCalculatorVM())
}
