//
//  GenerateBreadRecipeView.swift
//  BreadUp
//

import SwiftUI
import FoundationModels

struct GenerateBreadRecipeView: View {
    
    @Environment(BreadCalculatorVM.self) private var vm

    var body: some View {
        if let breadRecipe = vm.recipeBreadSequence
            , let titleBreadRecipe = breadRecipe.content.title,
           let steps = breadRecipe.content.pasos
        {
//            // ini prueba
//            Text(breadRecipe.rawContent.jsonString)
//            .padding()
//            .textSelection(.enabled)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            //end prueba
            VStack {
                Text(titleBreadRecipe)
                    .font(.title2.bold())
                LazyVStack (spacing: 12) {// breadRecipe.content.pasos
                    ForEach(steps) { step in
                        StepRow(step: step)
                    }
                }
            }
            //                        Button {
            //                            showSaveAlert = true
            //                        } label: {
            //                                HStack {
            //                                    Spacer()
            //                                    Label("Guardar receta", systemImage: "cooktop.fill")
            //                            }
            //                        }
//                                }
            
            //                .alert("Guardar receta", isPresented: $showSaveAlert) {
            //                    Button("No", role: .cancel) { }
            //                       Button("Sí") {
            //                           vm.save(context: modelContext)
            //                           dismiss()
            //                       }
            //                }
            .overlay {                                              // <-- NUEVO
                if vm.isLoading {                                   // <-- NUEVO
                    ZStack {                                        // <-- NUEVO
                        Color.black.opacity(0.4)                    // <-- NUEVO
                            .ignoresSafeArea()                      // <-- NUEVO
                                                                    //
                        VStack(spacing: 16) {                       // <-- NUEVO
                            ProgressView()                          // <-- NUEVO
                                .scaleEffect(1.5)                   // <-- NUEVO
                                .tint(.white)                       // <-- NUEVO
                            Text("Generando receta...")             // <-- NUEVO
                                .font(.headline)                    // <-- NUEVO
                                .foregroundStyle(.white)             // <-- NUEVO
                        }                                           // <-- NUEVO
                        .padding(32)                                // <-- NUEVO
                        .background(.ultraThinMaterial)              // <-- NUEVO
                        .clipShape(RoundedRectangle(cornerRadius: 16)) // <-- NUEVO
                    }                                               // <-- NUEVO
                    .transition(.opacity)                           // <-- NUEVO
                    .animation(.easeInOut, value: vm.isLoading)     // <-- NUEVO
                }                                                   // <-- NUEVO
            }                                                       // <-- NUEVO
            .allowsHitTesting(!vm.isLoading)
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
//                            vm.backToRecipeList()
//                    } label: {
//                            Label("Mis recetas", systemImage: "list.bullet")
//                    }
//                    .buttonStyle(.glass)
//                }
//            }
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
