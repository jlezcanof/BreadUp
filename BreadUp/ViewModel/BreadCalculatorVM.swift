//
//  BreadCalculatorViewModel.swift
//  BreadUp
//

import Foundation
import SwiftData
import FoundationModels
import Observation

@Observable @MainActor
final class BreadCalculatorVM {
    
    var water: Int = 250
    var flourType: FlourType = .wheat
    var flourQuantity: Int = 250
    var yeast: Int = 10
    var selectedDate: Date = Date()
    
    private let model: SystemLanguageModel
    private var session: LanguageModelSession
    
    var recipe : String?
    var isLoading = false
    var hasGenerationError = false
    var showRecipeDetail = false
    var navigateToGenerate = false
    var receivedTotalInformationAboutRecipe = false
    var alert = "Ha habido problemas para la generación de la receta. Por favor, inténtelo en unos minutos"
        
    private(set) var recipeBreadSequence: LanguageModelSession.ResponseStream<BreadRecipe>.Snapshot?
    
    private let options = GenerationOptions(temperature: 0.8, maximumResponseTokens: 1200)// 0.8....12000
        
    init() {
        model = SystemLanguageModel.default
        print("INIT: BEFORE SELF.SESSION")
        session = LanguageModelSession()
        print("INIT")
    }
    
    func initVM() {//modelContext: ModelContext
        // TODO "Actúa??
        let instructions = """
                    Eres un maestro panadero con 40 años de experiencia. Creas recetas de pan
                    reales y contrastadas, explicadas con un toque cercano y evocador.

                    Reglas:
                    1. Responde siempre en castellano.
                    2. Usa únicamente los ingredientes y cantidades que te dé el usuario.
                       Solo puedes añadir agua o sal si son imprescindibles, indicándolo.
                    3. Cada paso tiene un título corto (3 a 5 palabras) y una descripción
                       de 2 frases como máximo, con acción concreta, tiempos y temperaturas.
                    4. Si las proporciones no permiten hacer un pan viable, dilo al inicio
                       y propón el ajuste mínimo necesario.
                    5. Si te preguntan algo ajeno a la panadería, responde amablemente que
                       solo ayudas con recetas de pan.
        """
        
        //        self.session = LanguageModelSession(
        //                    tools:  [GetBreadRecipeTool()],
        //                    instructions: instructions)
        
        self.session = LanguageModelSession(model: model, instructions: instructions)
        // TODO prueba
//        session.prewarm()
        print("initVM")
    }
    
    private func availableLanguageModel() -> Bool {
        switch model.availability {
        case .available:
            return true
        case .unavailable(let reason):
        print("reason: \(reason)")
        return false
        }
    }
    
    func availableModel() -> SystemLanguageModel.Availability {
        model.availability
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
        
    func calculateRecipe() async {
            try? await self.generateRecipeBread()// se traga cualquier throw, prevenirlo
            print("end of calculateREcipe")
    }
    
    func navigateToGenerateView() async {
        navigateToGenerate = true
        await calculateRecipe()
    }
    
    func backToRecipeList() {
        navigateToGenerate = false
        showRecipeDetail = false
    }
        
    private func generateRecipeBread() async throws {
        guard availableLanguageModel() else {
            print("Language model not available")
            return
        }
        
        isLoading = true
        hasGenerationError = false
        defer { isLoading = false }
        
        do {
//            let stream = session.streamResponse(generating: BreadRecipe.self, includeSchemaInPrompt: false) {
//                    """
//                        Me vas a dar una receta para hacer pan. Lo más importante de todo son las especificaciones que me vas a dar para el tiempo de coción y su temperatura. Si en algún caso, no es un valor uniforme sino que se hace en varios intervalos de temperatura y tiempo, indícalo. Dámelo en 8 párrafos/pasos. Ingredientes/cantidades:
//                        - Agua: \(water) ml
//                        - Harina: \(flourType.rawValue), \(flourQuantity) ml
//                        - Levadura: \(yeast) g
//                    """
            
            
            // \(water)
            // Harina de \(flourType.rawValue): \(flourQuantity) gramos
            // Levadura fresca de panaderia: \(yeast) gramos.
            
            let prompt =
            """
                Crea una receta de pan casero usando estos ingredientes/cantidades:
                - Agua: \(water) mililitros
                - Harina de \(flourType.rawValue): \(flourQuantity) gramos
                - Levadura fresca de panaderia: \(yeast) gramos.
            """
            
        var partialCount = 0
        print("Agua \(water) harina \(flourType.rawValue) \(flourQuantity) y levadura \(yeast)")
            
            
        let stream = session.streamResponse(to: prompt, generating: BreadRecipe.self
                                                , options: options)
        for try await partial in stream {
            partialCount += 1
            self.recipeBreadSequence = partial
        }
        print("Total steps: \(partialCount)")
        receivedTotalInformationAboutRecipe = true
            
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize(let content) {
            print("exeeded content windows size")
            print("\(content.debugDescription)")
            self.alert = "Se ha excedido el contexto del tamaño de la ventana"
            hasGenerationError = true
        }
        catch LanguageModelSession.GenerationError.guardrailViolation(let content) {
            print("blocked by GUARDRAILS.")
            print("\(content.debugDescription)")
            self.alert = "No podemos responder a dicha petición de receta"
            hasGenerationError = true
        }
        catch LanguageModelSession.GenerationError.assetsUnavailable(let content) {
            print("Assets unavailable")
            print("\(content.debugDescription)")
            self.alert = "Los assets del modelo no están disponible"
            hasGenerationError = true
        }
        catch {
            if containsSafetyAssetFailure(error) {
                print("Safety classifier assets missing/corrupt")
//                self.recipe = "Los modelos de Apple Intelligence están actualizándose en tu dispositivo. Reintenta en unos minutos."
                self.alert  = "Los modelos de Apple Intelligence están actualizándose en tu dispositivo. Reintenta en unos minutos."
            } else {
                print(error)
//                self.recipe = "Por algún motivo desconocido, no podemos atender su petición."
                self.alert = "Por algún motivo desconocido, no podemos atender su petición."
            }
            hasGenerationError = true
        }
    }
    
    private func containsSafetyAssetFailure(_ error: Error) -> Bool {
        let ns = error as NSError

        if ns.domain == "com.apple.SensitiveContentAnalysisML" { return true }

        // Algunos errores meten varios underlying en esta clave (no estándar en NSError API).
        if let multiple = ns.userInfo[NSMultipleUnderlyingErrorsKey] as? [Error],
           multiple.contains(where: { containsSafetyAssetFailure($0) }) {
            return true
        }
        // El underlying "clásico".
        if let underlying = ns.userInfo[NSUnderlyingErrorKey] as? Error,
           containsSafetyAssetFailure(underlying) {
            return true
        }
        return false
    }
    
    private func makeStep() async throws -> RecipeStep {
        let prompt2 = """
            Genera un paso para la receta de un pan.
            
            La salida debe ser en un JSON, con la siguiente estructura:
            {
              "nameStep",
              "descriptionStep"
            }
            
            SOLO salida JSON, sin ’’’,
            """
        let response = try await session.respond(generating: RecipeStep.self) {
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
