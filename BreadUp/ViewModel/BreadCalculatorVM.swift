//
//  BreadCalculatorViewModel.swift
//  BreadUp
//

import Foundation
import SwiftData
import FoundationModels

@Observable
final class BreadCalculatorVM {
    
    var water: Int = 250
    var flourType: FlourType = .wheat
    var flourQuantity: Int = 250
    var yeast: Int = 10

    var time: Int = 0
    var temperature: Int = 0
    let prompt = """
    Generate a list of suggested search terms for an app about visiting famous landmarks
    """
    
    //"Cuál es la mejor manera de hacer una receta de pan"
    //let session: LanguageModelSession// = LanguageModelSession()
 
    var recipe : String?//= "" // Pulsa para probar
    
    init() {
//        self.session = LanguageModelSession(tools: [GetBreadRecipeTool()], instructions: "hola.")
    }


    // TODO pendiente de calcular
    func calculate() {
        let hydration = Double(water) / Double(flourQuantity)

        let flourFactor: Double = switch flourType {
        case .wheat:      1.0
        case .wholewheat:  1.15
        case .rye:         1.2
        case .spelt:       1.1
        case .corn:        1.25
        }

        let baseTime = 60.0 - (Double(yeast) * 0.8)
        let adjustedTime = baseTime * flourFactor * (1 + (hydration - 0.6) * 0.3)
        time = max(25, Int(adjustedTime.rounded()))

        let baseTemp: Double = switch flourType {
        case .wheat:      200
        case .wholewheat:  190
        case .rye:         195
        case .spelt:       185
        case .corn:        210
        }

        let tempAdjustment = (hydration - 0.6) * 15
        temperature = Int((baseTemp - tempAdjustment).rounded())
    }
    
    func resetResult() {
        time = 0
        temperature = 0
    }
    
    func save(context: ModelContext) {
        let ingredients = BreadUpIngredients(id: UUID(),water: water,
                                             flourType: flourType.toSchemaType, // flourType.toSchemaType
                                             flourQuantity: flourQuantity,
                                             yeast: yeast)
        
        let result = BreadUpCalculate(id: UUID(), time: time,
                                      temperature: temperature)
        
        ingredients.calculateBread = result
        
        context.insert(ingredients)
    }
    
    
    func prueba() {
        let value: String?? = .some(nil)
        
        print( value == nil)//false
//        print (value?.self == nil)
        print(value.self == nil)//
    }
        
    func calculateRecipe() {
        Task {
            try? await self.generateRecipeBread()
        }
    }
    
    private func generateRecipeBread() async throws {
        let session = LanguageModelSession(
            tools:  [GetBreadRecipeTool()], instructions: """
            Eres un panadero con más de 40 años de experiencia que ha realizado pan con todos los tipos de harinas posibles en el mercado.
            """)
      
        let prompt = """
            Me vas a dar una receta para hacer un pan con los ingredientes y cantidades indicadas. Lo más importante de todo son las especificaciones que me vas a dar para el tiempo de coción y su temperatura. Si en algún caso, no es un valor uniforme sino que se hace en varios intervalos de temperatura y tiempo, indícalo:
            - Agua: \(water) ml
            - Harina: \(flourType.rawValue), \(flourQuantity) ml
            - Levadura: \(yeast) g
        """
        
        let response = try await session.respond(to: prompt)
        self.recipe = response.content
        
        print(session.transcript)
        
        time = 1
        
    }
    
    
}
