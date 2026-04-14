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
    var selectedDate: Date = Date()
    
    //"Cuál es la mejor manera de hacer una receta de pan"
    let session: LanguageModelSession
    var recipe : String?
    var isLoading = false
    
    init() {
        self.session = LanguageModelSession(
                    tools:  [GetBreadRecipeTool()],
                    instructions: """
                    Eres un panadero con más de 40 años de experiencia que ha realizado pan con todos los tipos de harinas existentes en el mercado.
                    """)
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
                                             flourType: flourType.toSchemaType,
                                             flourQuantity: flourQuantity,
                                             yeast: yeast,
                                            createdAt: selectedDate)
        
        let result = BreadUpCalculate(id: UUID(), recipe: recipe ?? "")
        
        ingredients.calculateBread = result
        
        context.insert(ingredients)
    }
        
    func calculateRecipe() {
        Task {
            try? await self.generateRecipeBread()
        }
    }
    
    private func generateRecipeBread() async throws {
        isLoading = true                    // <-- NUEVO
        defer { isLoading = false }         // <-- NUEVO (se ejecuta siempre, incluso si hay error)
      
        let prompt = """
            Me vas a dar una receta para hacer pan. Lo más importante de todo son las especificaciones que me vas a dar para el tiempo de coción y su temperatura. Si en algún caso, no es un valor uniforme sino que se hace en varios intervalos de temperatura y tiempo, indícalo. No me des más de 8 pasos para su realización. Ingredientes/cantidades:
            - Agua: \(water) ml
            - Harina: \(flourType.rawValue), \(flourQuantity) ml
            - Levadura: \(yeast) g
        """
        
        do {
            let response = try await session.respond(to: prompt, options: GenerationOptions(sampling: .greedy, maximumResponseTokens: 500))
            self.recipe = response.content
//            var steps :  [StepRecipe] = []
//            for _ in 0 ..< 8 {
//                let stepRecipe = try await makeStep()
//                steps.append(stepRecipe)
//            }
//            
//            recipe = steps.enumerated()
//                .map { index, step in
//                    "Paso \(index + 1): \(step.nameStep) \n \(step.descriptionStep)"
//                }
//                .joined(separator: "\n\n")
//            
//            print("recipe \(String(describing: recipe))")
            
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
//            print("\(error)")
//            let newSession = newSession(previousSession: session)
        }
        
        print(session.transcript)
        time = 1 // TODO campo fuera
        
    }
    
    private func makeStep() async throws -> StepRecipe {
        let prompt2 = """
            Genera un paso para la receta de un pan.
            
            La salida debe ser en un JSON, con la siguiente estructura:
            {
              "nameStep",
              "descriptionStep"
            }
            
            SOLO salida JSON, sin ’’’,
            """
        let response = try await session.respond(generating: StepRecipe.self) {
            prompt2
        }
                                                 
        return response.content
    }
    
    private func newSession(previousSession: LanguageModelSession) -> LanguageModelSession {
        
        //        let allEntries = previousSession.transcript.entries
        
        var condensedEntries =  [Transcript.Entry]()
        
        //        if let firstEntry = allEntries.first {
//        condensedEntries.append(firstEntry)
//        if allEntries.count > 1, let lastEntry = allEntries.last {
//            condensedEntries.append(lastEntryy)
//        }
       //}
        
        let condensedTranscript = Transcript(entries: condensedEntries)
        // Note: transcript include instructions.
        return LanguageModelSession(transcript: condensedTranscript)
    }
    
    
}
