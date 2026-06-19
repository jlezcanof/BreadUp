//
//  BreadCalculatorViewModel.swift
//  BreadUp
//
import Foundation
import SwiftData
import FoundationModels
import Observation
import os

@Observable @MainActor
final class BreadCalculatorVM {
    
    var water: Int = 250
    var flourType: FlourType = .wheat
    var flourQuantity: Int = 250
    var yeast: Int = 10
    var selectedDate: Date = Date()
    
    private let model: SystemLanguageModel
    private var session: LanguageModelSession
//    private var context: ModelContext = nil
    
    var recipe : String?
    var recipeTitle: String = ""
    var recipeSteps: [RecipeStep] = []
    var isLoading = false
    var hasGenerationError = false
    var path: [Route] = []
    var receivedTotalInformationAboutRecipe = false
    var alert = "Ha habido problemas para la generación de la receta. Por favor, inténtelo en unos minutos"
    
    private static let log = Logger(
            subsystem: "com.josemanuel.lezcano.BreadUp",
            category: "FMDiagnostics"
        )
        
    private(set) var recipeBreadSequence: LanguageModelSession.ResponseStream<BreadRecipe>.Snapshot?
    
    private let options = GenerationOptions(temperature: 0.8, maximumResponseTokens: 1200)// 0.8....12000
        
    init() {
        model = SystemLanguageModel.default
        session = LanguageModelSession()
    }
    
    func initVM(modelContext: ModelContext) {
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
        
//        let instructions = """
//            Eres un humorista reputado con más de 30 años de reputación en las televisiones españolas, 
//        conociendo a todos los humoristas que existen en ese país.
//        """
        
        //        self.session = LanguageModelSession(
        //                    tools:  [GetBreadRecipeTool()],
        //                    instructions: instructions)
        
        session = LanguageModelSession(model: model, instructions: instructions)
        // TODO prueba
        session.prewarm()
//        self.context = modelContext
    }
    
    private func availableLanguageModel() -> Bool {
        switch model.availability {
            case .available:
                return true
            case .unavailable(let reason):
                Self.log.notice("Modelo no disponible: \(String(describing: reason), privacy: .public)")
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
        let ingredients = BreadUpIngredients(id: UUID(),
                                             water: water,
                                             flourType: flourType.toSchemaType,
                                             flourQuantity: flourQuantity,
                                             yeast: yeast,
                                            createdAt: selectedDate)
                
        let calculateBread = BreadUpCalculate(recipe: recipeTitle)
        
        recipeSteps.enumerated().forEach { index, recipeStep in
            calculateBread.steps.append(BreadUpStepRecipe(
                                                          order: index,
                                                          title: recipeStep.titulo,
                                                          descripcion: recipeStep.descripcion))
        }
        ingredients.calculateBread = calculateBread
        
        context.insert(ingredients)
        
        if context.hasChanges {
            try? context.save()
        }
    }
        
    private func calculateRecipe() async {
        try? await self.generateRecipeBread()// se traga cualquier throw, prevenirlo
    }
    
    func navigateToGenerateView() async {
        path.append(.generate)
        await calculateRecipe()
    }
    
    func backToRecipeList() {
        path.removeAll()
    }
        
    private func generateRecipeBread() async throws {
        guard availableLanguageModel() else {
            self.alert = "No está disponible el modelo del lenguaje"
            Self.log.notice("Modelo de lenguaje no disponible")
            return
        }
        
        isLoading = true
        hasGenerationError = false
        receivedTotalInformationAboutRecipe = false
        recipeBreadSequence = nil
        recipeTitle = ""
        recipeSteps = []
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

        let stream = session.streamResponse(to: prompt, generating: BreadRecipe.self
                                                , options: options)
        for try await partial in stream {
            self.recipeBreadSequence = partial
        }
        self.recipeTitle = recipeBreadSequence?.content.title ?? ""
        self.recipeSteps = (recipeBreadSequence?.content.pasos ?? []).compactMap { step in
            guard let titulo = step.titulo, let descripcion = step.descripcion else { return nil }
            return RecipeStep(titulo: titulo, descripcion: descripcion)
        }
        receivedTotalInformationAboutRecipe = true
            
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize(let content) {
            Self.log.error("Context window excedido: \(content.debugDescription, privacy: .public)")
            self.alert = "Se ha excedido el contexto del tamaño de la ventana"
            hasGenerationError = true
        }
        catch LanguageModelSession.GenerationError.guardrailViolation(let content) {
            Self.log.error("Bloqueado por guardrails: \(content.debugDescription, privacy: .public)")
            self.alert = "No podemos responder a dicha petición de receta"
            hasGenerationError = true
        }
        catch LanguageModelSession.GenerationError.assetsUnavailable(let content) {
            Self.log.error("Assets del modelo no disponibles: \(content.debugDescription, privacy: .public)")
            self.alert = "Los assets del modelo no están disponible"
            hasGenerationError = true
        }
        catch {
            if containsSafetyAssetFailure(error) {
                Self.log.error("Assets del clasificador de seguridad ausentes o corruptos")
//                self.recipe = "Los modelos de Apple Intelligence están actualizándose en tu dispositivo. Reintenta en unos minutos."
                self.alert  = "Los modelos de Apple Intelligence están actualizándose en tu dispositivo. Reintenta en unos minutos."
            } else {
                Self.log.error("Error de generación: \(String(describing: error), privacy: .public)")
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
    
    /// Recorre la jerarquía de NSError subyacentes hasta la raíz.
        private static func dump(_ error: Error) {
            var current: NSError? = error as NSError
            var level = 0
            while let ns = current {
                log.error("""
                       [\(level)] domain=\(ns.domain, privacy: .public) \
                    code=\(ns.code) desc=\(ns.localizedDescription, privacy: .public)
                    """)
                current = ns.userInfo[NSUnderlyingErrorKey] as? NSError
                level += 1
            }
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
