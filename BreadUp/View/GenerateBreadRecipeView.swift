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

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

  /// Controla la aparición animada (fade + scale sutil) de la cabecera resumen.
  @State private var headerAppeared = false

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

  /// Tarjeta de cabecera Liquid Glass: eyebrow del tipo de harina, título de
  /// la receta generada y tres "stat tiles" con las cantidades elegidas
  /// (color-coded por ingrediente). Conecta el resultado con lo pedido.
  private func summaryHeader(title: String) -> some View {
    GlassEffectContainer(spacing: 20) {
      headerCard(title: title)
    }
  }

  /// Contenido de la tarjeta + el fondo (glass o, si Reducir transparencia
  /// está activo, un fondo opaco equivalente) + la animación de aparición.
  private func headerCard(title: String) -> some View {
    let card =
      VStack(alignment: .leading, spacing: 16) {
        VStack(alignment: .leading, spacing: 4) {
          // Eyebrow: tipo de harina elegido, en el color de marca.
          HStack(spacing: 6) {
            Image(systemName: "tag.fill")
            Text(vm.flourType.displayName)
          }
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(Color("BreadFlour"))
          .accessibilityElement(children: .combine)
          .accessibilityLabel("Tipo de harina, \(vm.flourType.displayName)")

          Text(title)
            .font(.title2.bold())
            .foregroundStyle(.primary)
            .accessibilityAddTraits(.isHeader)
            .accessibilityFocused($recipeTitleFocused)
        }

        HStack(spacing: 12) {
          IngredientStatTile(
            icon: "leaf.fill",
            tint: Color("BreadFlour"),
            value: "\(vm.flourQuantity) g",
            name: "Harina",
            accessibilityLabel: "Harina, \(vm.flourQuantity) gramos"
          )
          IngredientStatTile(
            icon: "drop.fill",
            tint: Color("BreadWater"),
            value: "\(vm.water) ml",
            name: "Agua",
            accessibilityLabel: "Agua, \(vm.water) mililitros"
          )
          IngredientStatTile(
            icon: "bubbles.and.sparkles.fill",
            tint: Color("BreadYeast"),
            value: "\(vm.yeast) g",
            name: "Levadura",
            accessibilityLabel: "Levadura, \(vm.yeast) gramos"
          )
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(20)
      .background { decorativeMark }

    return Group {
      if reduceTransparency {
        // Reducir transparencia activo: fondo opaco equivalente, sin glass.
        card
          .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
              .fill(Color(.secondarySystemGroupedBackground))
          }
      } else {
        card
          .glassEffect(
            .regular.tint(Color("HeroTop").opacity(0.12)),
            in: .rect(cornerRadius: 28, style: .continuous)
          )
      }
    }
    .opacity(headerAppeared ? 1 : 0)
    .scaleEffect(headerAppeared ? 1 : 0.97, anchor: .top)
    .onAppear {
      withAnimation(reduceMotion ? nil : .smooth(duration: 0.4)) {
        headerAppeared = true
      }
    }
  }

  /// Marca de agua puramente decorativa (`fork.knife`) en la esquina
  /// superior-trailing de la tarjeta, recortada a su misma forma.
  private var decorativeMark: some View {
    Image(systemName: "fork.knife")
      .font(.system(size: 120))
      .foregroundStyle(Color("HeroBottom").opacity(0.06))
      .rotationEffect(.degrees(20))
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
      .offset(x: 24, y: -24)
      .clipShape(.rect(cornerRadius: 28, style: .continuous))
      .accessibilityHidden(true)
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

// MARK: - IngredientStatTile

/// Tile compacto tipo "stat" que muestra icono + valor destacado + etiqueta
/// para un ingrediente, con color-coding por tinte de marca. Reutilizable en
/// cualquier cabecera de receta.
private struct IngredientStatTile: View {

  let icon: String
  let tint: Color
  let value: String
  let name: String
  let accessibilityLabel: String

  var body: some View {
    VStack(spacing: 6) {
      Image(systemName: icon)
        .font(.headline)
        .foregroundStyle(tint)
      Text(value)
        .font(.title3.weight(.semibold))
        .foregroundStyle(.primary)
      Text(name)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
    .background {
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(tint.opacity(0.10))
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityLabel)
  }
}

#Preview {
  GenerateBreadRecipeView()
    .environment(BreadCalculatorVM(recipeIndexer: SpotlightRecipeIndexer()))
}
