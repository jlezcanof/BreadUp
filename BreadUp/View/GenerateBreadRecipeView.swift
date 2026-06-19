//
//  GenerateBreadRecipeView.swift
//  BreadUp
//

import SwiftUI
import FoundationModels
import SwiftData

struct GenerateBreadRecipeView: View {

    @Environment(BreadCalculatorVM.self) private var vm

    // provisional, deberiamos meterlo directamente en el VM
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showDatePicker = false
    @State private var showSaveDialog = false

    private static let bottomID = "recipeBottomAnchor"

    var body: some View {
        @Bindable var vm = vm
        return ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    if let breadRecipe = vm.recipeBreadSequence,
                        let titleBreadRecipe = breadRecipe.content.title,
                        let steps = breadRecipe.content.pasos
                    {
                        Text(titleBreadRecipe)
                            .font(.title2.bold())
                        LazyVStack(spacing: 16) {
                            ForEach(Array(steps.enumerated()), id: \.element.id)
                            { index, step in
                                StepRow(step: step, number: index + 1)
                            }
                        }
                    }
                    if vm.receivedTotalInformationAboutRecipe {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Button {
                                    withAnimation { showDatePicker.toggle() }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "calendar")
                                        Text(
                                            vm.selectedDate,
                                            format: .dateTime.day().month()
                                                .year()
                                        )
                                    }
                                    .font(.subheadline)
                                }
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.capsule)

                                Spacer(minLength: 12)

                                Button {
                                    showSaveDialog.toggle()
                                } label: {
                                    Label(
                                        "Guardar",
                                        systemImage: "tray.and.arrow.down"
                                    )
                                    .font(.headline)
                                }
                                .buttonStyle(.borderedProminent)
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
                            }
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 4)
                    }
                    // Ancla invisible al final del contenido: el auto-scroll apunta aquí.
                    Color.clear
                        .frame(height: 1)
                        .id(Self.bottomID)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            // Separa el contenido del borde inferior del scroll (incluida la
            // home indicator), de modo que el auto-scroll no pegue el último
            // elemento — la fila de acciones — al fondo del dispositivo.
            .contentMargins(.bottom, 28, for: .scrollContent)
            // Sigue al último paso mientras se va generando (cada token cambia
            // la descripción del último paso), al aparecer un paso nuevo (count)
            // y al completarse la receta.
            .onChange(
                of: vm.recipeBreadSequence?.content.pasos?.last?.descripcion
            ) {
                scrollToBottom(proxy)
            }
            .onChange(of: vm.recipeBreadSequence?.content.pasos?.count) {
                scrollToBottom(proxy)
            }
            .onChange(of: vm.receivedTotalInformationAboutRecipe) {
                scrollToBottom(proxy)
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
        .toolbarBackground(.visible, for: .navigationBar)
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
            Button("Cancelar", role: .cancel) { }
            Button("Guardar") {
                vm.save(context: modelContext)
                vm.backToRecipeList()
            }
        } message: {
            Text("¿Quieres guardar esta receta en tu recetario?")
        }
        //        .confirmationDialog(
        //            "¿Guardar esta receta?",
        //            isPresented: $showSaveDialog,
        //            titleVisibility: .visible
        //        ) {
        //            Button("Guardar") {
        //                vm.save(context: modelContext)
        //                vm.backToRecipeList()
        //            }
        //            Button("Cancelar", role: .cancel) { }
        //        } message: {
        //            Text("¿Quieres guardar esta receta en tu recetario?")
        //        }
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
