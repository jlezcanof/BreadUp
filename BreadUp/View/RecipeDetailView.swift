//
//  RecipeDetailView.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano Fresno on 8/4/26.
//

import FoundationModels
import SwiftData
import SwiftUI

struct RecipeDetailView: View {

  @Environment(BreadCalculatorVM.self) private var vm

  @State private var resultID = "resultado"

  var body: some View {
    @Bindable var vm = vm
    return ScrollViewReader { proxy in
      Form {
        Section("Harina") {
          Picker("Tipo de harina", selection: $vm.flourType) {
            ForEach(FlourType.allCases) { type in
              Text(type.rawValue).tag(type)
            }
          }
          VStack(alignment: .leading) {
            Text("\(vm.flourQuantity) g")
              .font(.headline)
            Slider(
              value: Binding(
                get: { Double(vm.flourQuantity) },
                set: { vm.flourQuantity = Int($0) }
              ),
              in: 125...400,
              step: 25
            )
            .accessibilityLabel("Cantidad de harina")
            .accessibilityValue("\(vm.flourQuantity) gramos")
            HStack {
              Text("125 g")
              Spacer()
              Text("400 g")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .accessibilityHidden(true)
          }
        }
        Section("Levadura") {
          yeast
          sliderYeast
          HStack {
            Text("5 g")
            Spacer()
            Text("50 g")
          }
          .font(.caption)
          .foregroundStyle(.secondary)
          .accessibilityHidden(true)
        }
        Section("Agua") {
          VStack(alignment: .leading) {
            water
            Slider(
              value: Binding(
                get: { Double(vm.water) },
                set: { vm.water = Int($0) }
              ),
              in: 125...500,
              step: 25
            )
            .accessibilityLabel("Cantidad de agua")
            .accessibilityValue("\(vm.water) mililitros")
            HStack {
              Text("125 ml")
              Spacer()
              Text("500 ml")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .accessibilityHidden(true)
          }
        }
        Section {
          Button {
            Task {
              await vm.navigateToGenerateView()
            }
          } label: {
            Label("Generar receta", systemImage: "sparkles")
              .frame(maxWidth: .infinity)
              .font(.headline)
          }
          //.buttonStyle(.borderedProminent)//prueba
          .disabled(!isModelAvailable)
        } footer: {
          if let unavailableNote {
            Text(unavailableNote)
          }
        }
      }
      .onChange(of: vm.water) { vm.resetResult() }
      .onChange(of: vm.flourType) { vm.resetResult() }
      .onChange(of: vm.flourQuantity) { vm.resetResult() }
      .onChange(of: vm.yeast) { vm.resetResult() }
      .navigationTitle("Nueva receta")
    }
    .loadingOverlay(vm.isLoading, message: "Generando receta…")
    .alert("Esa receta ya existe", isPresented: $vm.hasDuplicateError) {
      Button("De acuerdo", role: .cancel) {}
    } message: {
      Text("Ya tienes guardada una receta con estos ingredientes y fecha.")
    }
  }

  /// El modelo está disponible para generar.
  private var isModelAvailable: Bool {
    if case .available = vm.availableModel() { return true }
    return false
  }

  /// Nota explicativa (footer) cuando la generación no está disponible.
  private var unavailableNote: String? {
    guard case .unavailable(let reason) = vm.availableModel() else { return nil }
    switch reason {
    case .appleIntelligenceNotEnabled:
      return "Activa Apple Intelligence en los Ajustes del sistema para generar recetas."
    case .modelNotReady:
      return "El modelo se está preparando. Vuelve a intentarlo en unos minutos."
    case .deviceNotEligible:
      return "Este dispositivo no es compatible con la generación de recetas."
    @unknown default:
      return "La generación de recetas no está disponible ahora mismo."
    }
  }

  private var water: some View {
    Text("\(vm.water) ml")
      .font(.headline)
  }

  private var yeast: some View {
    Text("\(vm.yeast) g")
      .font(.headline)
  }

  private var sliderYeast: some View {
    Slider(
      value: Binding(
        get: { Double(vm.yeast) },
        set: { vm.yeast = Int($0) }
      ),
      in: 5...50,
      step: 5,
      onEditingChanged: { editing in
        //                            isEditing = editing
        //                                if editing {
        //                                    print("Empieza a mover el slider")
        //                                } else {
        //                                    print("Termina de mover el slider")
        //                                    // Aquí haces algo pesado: guardar, enviar, etc.
        //                                }
      }
    )
    .accessibilityLabel("Cantidad de levadura")
    .accessibilityValue("\(vm.yeast) gramos")
  }

  private let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnly)
  //      .inlineOnlyPreservingWhitespace
}

#Preview {
  RecipeDetailView()
}
