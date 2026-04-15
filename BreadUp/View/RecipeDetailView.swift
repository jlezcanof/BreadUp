//
//  RecipeDetailView.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano Fresno on 8/4/26.
//

import SwiftUI
import SwiftData
import FoundationModels

struct RecipeDetailView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var vm = BreadCalculatorVM()
    
    @State private var resultID = "resultado"
    @State private var showSaveAlert = false
    @State private var showDatePicker = false
    
    private let model = SystemLanguageModel.default
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                Form {
                    Section("Foundation Model") {
                        switch model.availability {
                                case .available:
                                    Text("Foundation Model is available").foregroundStyle(.green)
                                case .unavailable(let reason):
                                    Text("Foundation Model is unavailable").foregroundStyle(.red)
                                    Text(verbatim: String(describing: reason))
                                }
                    }
                    Section("Harina") {
                        Picker("Tipo de harina", selection: $vm.flourType) {
                            ForEach(FlourType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        VStack(alignment: .leading) {
                            Text("\(vm.flourQuantity) ml")
                                .font(.headline)
                            Slider(
                                value: Binding(
                                    get: { Double(vm.flourQuantity) },
                                    set: { vm.flourQuantity = Int($0) }
                                ),
                                in: 125...400,
                                step: 25
                            )
                            HStack {
                                Text("125 ml")
                                Spacer()
                                Text("400 ml")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }

                    Section("Levadura") {
                        Text("\(vm.yeast) gramos")
                            .font(.headline)
                        Slider(
                            value: Binding(
                                get: { Double(vm.yeast) },
                                set: { vm.yeast = Int($0) }
                            ),
                            in: 5...50,
                            step:5,
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
                        HStack {
                            Text("5 gr")
                            Spacer()
                            Text("50 gr")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    Section("Agua") {
                        VStack(alignment: .leading) {
                            Text("\(vm.water) ml")
                                .font(.headline)
                            Slider(
                                value: Binding(
                                    get: { Double(vm.water) },
                                    set: { vm.water = Int($0) }
                                ),
                                in: 125...500,
                                step: 25
                            )
                            HStack {
                                Text("125 ml")
                                Spacer()
                                Text("500 ml")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
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
                                Text(vm.selectedDate, format: .dateTime.day().month().year())
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
                    
                    switch model.availability {
                        
                    case .available:
                            Button {
                                vm.calculateRecipe()
                            } label: {
                                Label("Generar receta", systemImage: "sparkles")// apple.intelligence
                                .frame(maxWidth: .infinity)
                                .font(.headline)
                            }
                    case .unavailable(.appleIntelligenceNotEnabled):
                            HStack {
                                    Text("El calculador de recetas de pan no está disponible porque Apple Inteligence no está habilitado")
                            }
                    case .unavailable(.modelNotReady):
                            HStack {
                                        Text("Calculador de recetas de pan aún no está listo. Inténtalo más tarde ")
                            }
                    case .unavailable(.deviceNotEligible):
                        HStack {
                                    Text("Calculador de recetas de pan aún no está listo. Inténtalo más tarde ")
                        }
                    default:
                        Text("model.availabiltiy.default")
                    }
                    
               
                    Section("Receta") {
                        if let recipe = vm.recipe {
                                if let messageMD = try? AttributedString(markdown: recipe, options: options) {
                                ScrollView {
                                        Text(messageMD)
                                            .padding()
                                            .textSelection(.enabled)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                        }
                        Button {
                            // TODO decidir que guardar aqui
                            showSaveAlert = true
                        } label: {
                                HStack {
                                    Spacer()
                                    Label("Guardar receta", systemImage: "cooktop.fill")
                            }
                        }
                    }
                    .id(resultID)
                }
                .onChange(of: vm.water) {vm.resetResult()}
                .onChange(of: vm.flourType) {vm.resetResult()}
                .onChange(of: vm.flourQuantity) {vm.resetResult()}
                .onChange(of: vm.yeast) {vm.resetResult()}
                .onChange(of: vm.time) {
                    if vm.time > 0 {
                        withAnimation {
                            proxy.scrollTo(resultID, anchor: .bottom)
                        }
                    }
                }
                .alert("Guardar receta", isPresented: $showSaveAlert) {
                    Button("No", role: .cancel) { }
                       Button("Sí") {
                           vm.save(context: modelContext)
                           dismiss()
                       }
                }
                .navigationTitle("BreadUp")
            }
        }
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
        .allowsHitTesting(!vm.isLoading)                        // <-- NUEVO (bloquea la interacción
    }
    
    private let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnly)
    //      .inlineOnlyPreservingWhitespace
}

#Preview {
    RecipeDetailView()
}
