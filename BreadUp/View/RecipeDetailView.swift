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
    @Environment(\.dismiss) private var dismiss

    @State private var resultID = "resultado"

    private var canGenerate: Bool {
        return !vm.hydrationNotPermitted  //isModelAvailable &&
    }

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
                        Label("Generar receta", systemImage: "sparkles.2")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                    //                    .buttonStyle( !canGenerate ? .glass : .glassProminent)// .glassProminent : .glass
                    //          // !isModelAvailable || && !...true....!vm.hydrationNotPermitted
                    .disabled(!canGenerate)
                    .grayscale(canGenerate ? 0 : 1)
                    .opacity(canGenerate ? 1 : 0.6)
                    .animation(.easeInOut(duration: 0.2), value: canGenerate)
                }
                //                footer: {
                //                    if let unavailableNote {
                //                        Text(unavailableNote)
                //                            .font(.footnote)
                //                    }
                //                }
            }
            .navigationTitle("Nueva receta")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
        .loadingOverlay(vm.isLoading, message: "Generando receta…")
        .onAppear {
            vm.calculateHydratation()
            //TODO deberiamos mostrar un mensaje de que debe de tener en cuenta la hidratación de la masa
        }
        .onChange(of: vm.water) { vm.verifyHidration() }
        .onChange(of: vm.flourType) { vm.verifyHidration() }
        .onChange(of: vm.flourQuantity) { vm.verifyHidration() }
        .alert(
            vm.alertHydrationNotPermmited,
            isPresented: $vm.showHidrationAlert
        ) {
            Button("De acuerdo", role: .cancel) {}
        } message: {
            Text(
                "Ajuste sus valores de agua y harina para tener la hidratación más adecuada para la masa"
            )
        }
    }

    // El modelo está disponible para generar.
    private var isModelAvailable: Bool {
        if case .available = vm.availableModel() { return true }
        return false
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

    //  private let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnly)
    //      .inlineOnlyPreservingWhitespace
}

#Preview {
  RecipeDetailView()
}
