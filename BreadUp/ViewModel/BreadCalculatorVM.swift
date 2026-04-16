//
//  BreadCalculatorViewModel.swift
//  BreadUp
//

import Foundation
import SwiftData
import FoundationModels
import Observation

@Observable
final class BreadCalculatorVM {
    
    var water: Int = 250
    var flourType: FlourType = .wheat
    var flourQuantity: Int = 250
    var yeast: Int = 10
    var selectedDate: Date = Date()
    
    //"Cuál es la mejor manera de hacer una receta de pan"
    private let session: LanguageModelSession
    var recipe : String?
    var isLoading = false
    
    private(set) var recipeBread: BreadRecipe?
    
    private(set) var recipeBreadSequence: LanguageModelSession.ResponseStream<BreadRecipe>.Snapshot?
    
    init() {
        var instructions = """
                    Eres un maestro panadero con más de 40 años de experiencia que ha realizado pan con todos los tipos de harinas existentes en el mercado.
                    """
        instructions.append("Vas a obtener recetas de pan en función de los ingredientes y cantidades indicadas. Aqui tienes un ejemplo \(BreadRecipe.exampleRecipeBread)")
        
        
        self.session = LanguageModelSession(
                    tools:  [GetBreadRecipeTool()],
                    instructions: instructions)
        
//                            """
//                            Eres un maestro panadero con más de 40 años de experiencia que ha realizado pan con todos los tipos de harinas existentes en el mercado.
//                            """
        
//        let otherSession = LanguageModelSession(tools:  [GetBreadRecipeTool()]) {
//            "Your job is to create an recipe of the bread"
//        }
    }


    // TODO pendiente de calcular
    func calculate() {
//        let hydration = Double(water) / Double(flourQuantity)
//
//        let flourFactor: Double = switch flourType {
//        case .wheat:      1.0
//        case .wholewheat:  1.15
//        case .rye:         1.2
//        case .spelt:       1.1
//        case .corn:        1.25
//        }
//
//        let baseTime = 60.0 - (Double(yeast) * 0.8)
//        let adjustedTime = baseTime * flourFactor * (1 + (hydration - 0.6) * 0.3)
//        time = max(25, Int(adjustedTime.rounded()))
//
//        let baseTemp: Double = switch flourType {
//        case .wheat:      200
//        case .wholewheat:  190
//        case .rye:         195
//        case .spelt:       185
//        case .corn:        210
//        }
//
//        let tempAdjustment = (hydration - 0.6) * 15
//        temperature = Int((baseTemp - tempAdjustment).rounded())
    }
    
    func resetResult() {
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
//            try? await self.generateRecipeBread()
//            try? await self.suggestRecipeBread()
            try? await self.suggestSequenceBread()
            print("end of calculateREcipe")
        }
    }
    
    private func generateRecipeBread() async throws {
        isLoading = true                    // <-- NUEVO
        defer { isLoading = false }         // <-- NUEVO (se ejecuta siempre, incluso si hay error)
      
        let prompt = """
            Me vas a dar una receta para hacer pan. Lo más importante de todo son las especificaciones que me vas a dar para el tiempo de coción y su temperatura. Si en algún caso, no es un valor uniforme sino que se hace en varios intervalos de temperatura y tiempo, indícalo. Dámelo en 8 párrafos/pasos. Ingredientes/cantidades:
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
            print("exeeded content windows size")
//            print("\(error)")
//            let newSession = newSession(previousSession: session)
        }
        catch LanguageModelSession.GenerationError.guardrailViolation {
            print("safety guard rail violation ocurred.")
        }
        print(session.transcript)
    }
    
    private func suggestRecipeBread() async throws {
        isLoading = true                    // <-- NUEVO
        defer { isLoading = false }         // <-- NUEVO (se ejecuta siempre, incluso si hay error)
        let response = try await session.respond(generating: BreadRecipe.self) {
                    """
                        Me vas a dar una receta para hacer pan. Lo más importante de todo son las especificaciones que me vas a dar para el tiempo de coción y su temperatura. Si en algún caso, no es un valor uniforme sino que se hace en varios intervalos de temperatura y tiempo, indícalo. Dámelo en 8 párrafos/pasos. Ingredientes/cantidades:
                        - Agua: \(water) ml
                        - Harina: \(flourType.rawValue), \(flourQuantity) ml
                        - Levadura: \(yeast) g
                    """
        }
        self.recipeBread = response.content
        //        print("\(self.recipeBread, default: "nada de nada")")

        
        let recipeString = self.recipeBread?.steps.enumerated()
            .map { index, step in
                "Paso \(index + 1): \(step.nameStep)\n\(step.descriptionStep)"
            }
            .joined(separator: "\n\n")
        
        self.recipe = recipeString
    }
    
    private func suggestSequenceBread() async throws {
        isLoading = true
        defer { isLoading = false }
        prewarn()
        let stream = session.streamResponse(generating: BreadRecipe.self, includeSchemaInPrompt: false) {
                    """
                        Me vas a dar una receta para hacer pan. Lo más importante de todo son las especificaciones que me vas a dar para el tiempo de coción y su temperatura. Si en algún caso, no es un valor uniforme sino que se hace en varios intervalos de temperatura y tiempo, indícalo. Dámelo en 8 párrafos/pasos. Ingredientes/cantidades:
                        - Agua: \(water) ml
                        - Harina: \(flourType.rawValue), \(flourQuantity) ml
                        - Levadura: \(yeast) g
                    """
        }
        
        for try await partial in stream {
            self.recipeBreadSequence = partial
        }
    }
    
    private func prewarn() {
        self.session.prewarm()
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
    
 
    
//    private func newSession(previousSession: LanguageModelSession) -> LanguageModelSession {
//        
//        //        let allEntries = previousSession.transcript.entries
//        
//        var condensedEntries =  [Transcript.Entry]()
//        
//        //        if let firstEntry = allEntries.first {
////        condensedEntries.append(firstEntry)
////        if allEntries.count > 1, let lastEntry = allEntries.last {
////            condensedEntries.append(lastEntryy)
////        }
//       //}
//        
//        let condensedTranscript = Transcript(entries: condensedEntries)
//        // Note: transcript include instructions.
//        return LanguageModelSession(transcript: condensedTranscript)
//    }
    
    
}

//let intent = BreadRecipeIn
