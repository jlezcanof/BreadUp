//
//  ContentView.swift
//  BreadUp
//
//  Created by Yomismista on 25/3/26.
//

import SwiftUI

struct ContentView: View {
    @State private var vm = BreadCalculatorVM()
    @State private var resultID = "resultado"

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                Form {
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
                                if editing {
                                    print("Empieza a mover el slider")
                                } else {
                                    print("Termina de mover el slider")
                                    // Aquí haces algo pesado: guardar, enviar, etc.
                                }
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

                    Section {
                        Button {
                            vm.calculate()
                            withAnimation {
                                proxy.scrollTo(resultID, anchor: .bottom)
                            }
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
                        }
                        .id(resultID)
                    }
                }
                .onChange(of: vm.water) {vm.resetResult()}
                .onChange(of: vm.flourType) {vm.resetResult()}
                .onChange(of: vm.flourQuantity) {vm.resetResult()}
                .onChange(of: vm.yeast) {vm.resetResult()}
                .navigationTitle("BreadUp")
            }
        }
    }
}

#Preview {
    ContentView()
}
