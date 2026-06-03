//
//  Tooling.swift
//  BreadUp
//
//  Created by Yomismista on 16/4/26.
//

import FoundationModels


@Generable
enum CategoriaHarina: String, CaseIterable, Identifiable {
    case trigo
    case centeno
    case cebada
    case avena
    case maiz
    case mijo
    case sorgo
    case telf
    case arroz
    
    var id: String { rawValue }
}

enum CategoriaLevadura: String, CaseIterable, Identifiable {
    case secaActiva
    case secaInstantanea
    case natural
    case deshidratada
    
    var id: String { rawValue }
}

struct GetBreadRecipeTool: Tool {
    
    let name = "recipeBread"

    let description = "Consulta el método de preparación de una receta de pan con los ingredientes y cantidades recibidas"

    let includesSchemaInInstructions = false

    @Generable
    struct BreadArguments {
        // Aqui vamos a poner todos los ingredientes y su cantidad

        @Guide(description: "Cantidad de agua")
        var water: Int

        @Guide(description: "Tipo de harina")
        var categoriaHarina: CategoriaHarina

        @Guide(description: "Cantidad de harina")
        var cantidadHarina: Int

        @Guide(description: "Cantidad de levadura")
        var yeast: Int

        @Guide(description: "Tiempo de horneado")
        var time: Int

        @Guide(description: "Temperatura aconsejable para la cocción")
        var temperature: Int
    }

    func call(arguments: BreadArguments) async throws -> String {
//        CNContactStore()
//        let output = ToolOutput(water: arguments.water,
//                                flourType: arguments.flourType,
//                                flourQuantity: arguments.flourQuantity,
//                                yeast: arguments.yeast)
//
//        return output
        
//        try await MainActor.run {
//            try store.
//        }
        return ""
    }

}

//struct ToolOutput : PromptRepresentable {
//
//    var water: Int
//
//    var flourType: String
//
//    var flourQuantity: Int
//
//    var yeast: Int
//
//    // Aqui podremos el prompt de usuario indicando la cantidad de los ingredientes y que queremos hacer pan
//    nonisolated var promptRepresentation: Prompt {
//        """
//            Bread result:
//            - Preparation method for making break: \(water)
//        """
//    }
//
//}
