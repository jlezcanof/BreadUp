//
//  Generable.swift
//  BreadUp
//
//  Created by Yomismista on 9/4/26.
//

import FoundationModels

@Generable()
struct SearchSuggestions {
    
    @Guide(description: "A list of suggested search terms", .count(1))//Una receta de como hacer pan
    var searchTerms: [String]  
}


@Generable()
struct Pan {
    var consejos: String
}


struct GetBreadRecipeTool : Tool {
    
    typealias Output = ToolOutput
    
    typealias Arguments = BreadArguments
    
    @Generable
    struct BreadArguments {
        
        @Guide(description: "The number of bread recipes to fetch")
        var recipe: String
        
        // Aqui vamos a poner todos los ingredientes y su cantidad
    }
    
    let name = "getBreadRecipeTool"
    
    let description = "Obtener la mejor receta para hacer pan"
    
//    let parameters: GenerationSchema
    
    func call(arguments: Arguments) async throws -> ToolOutput? {
        
//        let content = GeneratedContent(properties: ["pepe" : arguments.recipe])
//
////        let content = GeneratedContent(properties: ["temperature": temperature])
////        let ouput = ToolOutput(content)
//        
//        let output = ToolOutput()
//        return output
        
        return nil
    }
}

//@MainActor
struct ToolOutput : PromptRepresentable, Sendable {
    
    let promptRepresentation: Prompt
    
    
    
}
