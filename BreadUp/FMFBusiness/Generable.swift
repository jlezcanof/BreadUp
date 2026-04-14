//
//  Generable.swift
//  BreadUp
//
//  Created by Yomismista on 9/4/26.
//
import FoundationModels


@Generable
struct StepRecipe {// : Codable
    let nameStep: String
    let descriptionStep: String
    
    // Macro-generated
    static var schema: GenerationSchema {
        GenerationSchema(type: StepRecipe.self, properties: [
            GenerationSchema.Property(name: "nameStep",description: "Name of the step of recipe a bread", type: String.self),
            GenerationSchema.Property(name: "descriptionStep", description: "Detailed description",  type: String.self),
        ])
    }
}

//extension StepRecipe: Generable {
//    init(_ content: GeneratedContent) throws {
//        self.nameStep = try content.value(forProperty: "nameStep")
//        self.descriptionStep = try content.value(forProperty: "descriptionStep")
//    }
//}

struct GetBreadRecipeTool: Tool {
        
    typealias Output = ToolOutput
    
    typealias Arguments = BreadArguments
    
    let name = "calculate_break"
    
    let description = "Calculates the preparation method for the recipe bread with the given ingredients"
    
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
