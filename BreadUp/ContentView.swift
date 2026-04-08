//
//  ContentView.swift
//  BreadUp
//
//  Created by Yomismista on 25/3/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = BreadCalculatorVM()

    var body: some View {
        NavigationStack {
            Form {
                Section("Agua") {
                    VStack(alignment: .leading) {
                        Text("\(viewModel.water) ml")
                            .font(.headline)
                        Slider(
                            value: Binding(
                                get: { Double(viewModel.water) },
                                set: { viewModel.water = Int($0) }
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
                    Picker("Tipo de harina", selection: $viewModel.flourType) {
                        ForEach(FlourType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("\(viewModel.flourQuantity) ml")
                            .font(.headline)
                        Slider(
                            value: Binding(
                                get: { Double(viewModel.flourQuantity) },
                                set: { viewModel.flourQuantity = Int($0) }
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
                    Stepper(
                        "\(viewModel.yeast) gramos",
                        value: $viewModel.yeast,
                        in: 5...50,
                        step: 5
                    )
                }

                Section {
                    Button {
                        viewModel.calculate()
                    } label: {
                        Text("Calcular")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                }

                if viewModel.time > 0 {
                    Section("Resultado") {
                        LabeledContent("Tiempo", value: "\(viewModel.time) minutos")
                        LabeledContent("Temperatura", value: "\(viewModel.temperature) °C")
                    }
                }
            }
            .navigationTitle("BreadUp")
        }
    }
}

#Preview {
    ContentView()
}
