//
//  Tooling.swift
//  BreadUp
//
//  Created by Yomismista on 16/4/26.
//
import FoundationModels

struct GetBreadRecipeTool: Tool {
    
    let name = "recipeBread"// calculate_break

    let description = "Calculates the preparation method for the recipe bread with the given ingredients"
//    let description = "Pasos para hacer un muñeco de papel con papiroflexia"

    typealias Output = ToolOutput

    typealias Arguments = BreadArguments

    let includesSchemaInInstructions = false

    @Generable
    struct BreadArguments {
        // Aqui vamos a poner todos los ingredientes y su cantidad

//        @Guide(description: "The quantity of water")
        var water: Int

//        @Guide(description: "Type of flour")
        var flourType: String

//        @Guide(description: "The quantity of flour")
        var flourQuantity: Int

//        @Guide(description: "The quantity of yeast")
        var yeast: Int

//        @Guide(description: "The number of bread recipes to fetch")
        var time: Int

//        @Guide(description: "The number of bread recipes to fetch")
        var temperature: Int
    }

    func call(arguments: BreadArguments) async throws -> ToolOutput {
//        CNContactStore()
        let output = ToolOutput(water: arguments.water,
                                flourType: arguments.flourType,
                                flourQuantity: arguments.flourQuantity,
                                yeast: arguments.yeast)

        return output
    }

}

struct ToolOutput : PromptRepresentable {

    var water: Int

    var flourType: String

    var flourQuantity: Int

    var yeast: Int

    // Aqui podremos el prompt de usuario indicando la cantidad de los ingredientes y que queremos hacer pan
    nonisolated var promptRepresentation: Prompt {
        """
            Bread result:
            - Preparation method for making break: \(water)
        """
    }

}
