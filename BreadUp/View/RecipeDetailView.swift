//
//  RecipeDetailView.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano Fresno on 8/4/26.
//

import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var vm = BreadCalculatorVM()
    @State private var resultID = "resultado"
    @State private var showSaveAlert = false

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                Form {

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
                    Section {
                        Button {
                            vm.calculate()
                        } label: {
                            Text("Calcular")
                                .frame(maxWidth: .infinity)
                                .font(.headline)
                        }
                    }
                    if vm.time > 0 {
                        Section("Resultado") {
                            LabeledContent("Tiempo", value: "\(vm.time) minutos")
                            LabeledContent("Temperatura", value: "\(vm.temperature) °C")
                            
                            Button {
                                // vm.save(context: modelContext)
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
    }
}

#Preview {
    RecipeDetailView()
}
