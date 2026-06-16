//
//  GenerateBreadRecipeView.swift
//  BreadUp
//

import SwiftUI
import FoundationModels

struct GenerateBreadRecipeView: View {
    
    @Environment(BreadCalculatorVM.self) private var vm
    
    @State private var showDatePicker = false

    var body: some View {
        @Bindable var vm = vm
        return ScrollView {
            VStack(spacing: 16) {
                if let breadRecipe = vm.recipeBreadSequence,
                   let titleBreadRecipe = breadRecipe.content.title,
                   let steps = breadRecipe.content.pasos
                {
                    Text(titleBreadRecipe)
                        .font(.title2.bold())
                    LazyVStack(spacing: 12) {
                        ForEach(steps) { step in
                            StepRow(step: step)
                        }
                    }
                }
                if vm.receivedTotalInformationAboutRecipe {
                    //INI WIP
                    Section("Fecha") {
                        Button {
                            withAnimation {
                                showDatePicker.toggle()
                            }
                        } label: {
                            HStack {
                                Text("Fecha de elaboración")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(
                                    vm.selectedDate,
                                    format: .dateTime.day().month().year()
                                )
                                .foregroundStyle(.secondary)
                            }
                        }
                        if showDatePicker {
                            DatePicker(
                                "Fecha de elaboración",
                                selection: $vm.selectedDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .onChange(of: vm.selectedDate) {
                                withAnimation {
                                    showDatePicker = false
                                }
                            }
                        }
                    }
                    //END WIP
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if vm.isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Generando receta...")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .padding(32)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .transition(.opacity)
                .animation(.easeInOut, value: vm.isLoading)
            }
        }
        .allowsHitTesting(!vm.isLoading)
        .navigationTitle("Receta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert(vm.alert, isPresented: $vm.hasGenerationError
        ) {
            Button("Cerrar") {
                vm.hasGenerationError = false
                vm.navigateToGenerate = false
            }
        }
    }
    
    private struct StepRow: View {
        
        let step: RecipeStep.PartiallyGenerated
        
        var body: some View {
            if let titulo = step.titulo, let descripcion = step.descripcion {
                VStack(alignment: .leading, spacing: 10) {
                    Text(titulo)
                        .font(.title3.bold())
                    Text(descripcion)
                        .font(.body)
                }
            }
        }
    }
 
}

#Preview {
    GenerateBreadRecipeView()
        .environment(BreadCalculatorVM())
}
