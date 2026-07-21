//
//  BreadCalculatorViewModel.swift
//  BreadUp
//
import Foundation
import FoundationModels
import Observation
import SwiftData
import os

@Observable @MainActor
final class BreadCalculatorVM {

    var water: Int = 125
    var flourType: FlourType = .wheat
    var flourQuantity: Int = 125
    var yeast: Int = 5
    var selectedDate: Date = Date()

    var time: Int = 0
    var temperature: Int = 0
    // Temperatura objetivo en el centro de la miga (criterio real de cocción,
    // según ThermoWorks/Wordloaf). Más fiable que el tiempo de horneado.
    var internalTemperature: Int = 0

    private let model: SystemLanguageModel
    private var session: LanguageModelSession
    private var modelContext: ModelContext?

    var recipe: String?
    var recipeTitle: String = ""
    var recipeSteps: [RecipeStep] = []
    var isLoading = false
    var hasGenerationError = false

    // La receta que se intenta generar ya existe (mismos ingredientes y fecha).
    // La pantalla de ingredientes observa este flag para avisar sin navegar.
    var hasDuplicateError = false
    var hydrationNotPermitted = false  // Estado de validez - controla el botón
    var showHidrationAlert = false  //presentación del alert - independiente
    var alertHydrationNotPermmited = ""

    var path: [Route] = []
    var receivedTotalInformationAboutRecipe = false
    var alert =
        "Ha habido problemas para la generación de la receta. Por favor, inténtelo en unos minutos"

    private static let log = Logger(
        subsystem: "com.josemanuel.lezcano.BreadUp",
        category: "FMDiagnostics"
    )

    private(set) var recipeBreadSequence:
        LanguageModelSession.ResponseStream<BreadRecipe>.Snapshot?

    // 0.8....12000
    private let options = GenerationOptions(
        temperature: 0.8,
        maximumResponseTokens: 1200
    )

    // TODO "Actúa??
    private let instructions = """
                    Eres un maestro panadero con 40 años de experiencia. Creas recetas de pan
                    reales y contrastadas, explicadas con un toque cercano y evocador.

                    Reglas:
                    1. Responde siempre en castellano.
                    2. Usa únicamente los ingredientes y cantidades que te dé el usuario.
                       Solo puedes añadir agua o sal si son imprescindibles, indicándolo.
                    3. Cada paso tiene un título corto (3 a 5 palabras) y una descripción
                       de 2 frases como máximo, con una acción concreta, tiempos y temperaturas.
                    4. Si te preguntan con algo ajeno a la panadería, responde amablemente que
                       solo ayudas con temas relacionados con la eleboración de pan.
        """
    
    //      4. Si las proporciones no permiten hacer un pan viable, dilo al inicio
    //         y propón el ajuste mínimo necesario.
    //      5. El título de la receta debe ser SIEMPRE único, no se puede NUNCA repetir.
    
    private let recipeIndexer: any RecipeIndexing

    init(recipeIndexer: RecipeIndexing) {
        self.recipeIndexer = recipeIndexer
        model = SystemLanguageModel.default
        session = LanguageModelSession()
    }

    func initVM(modelContext: ModelContext) {
        self.modelContext = modelContext

        // TODO incluir Tool....
        //        self.session = LanguageModelSession(
        //                    tools:  [GetBreadRecipeTool()],
        //                    instructions: instructions)

        session = LanguageModelSession(model: model, instructions: instructions)
        session.prewarm()
    }

    private func availableLanguageModel() -> Bool {
        switch model.availability {
        case .available:
            return true
        case .unavailable(let reason):
            Self.log.notice(
                "Modelo no disponible: \(String(describing: reason), privacy: .public)"
            )
            return false
        }
    }

    func availableModel() -> Bool {
        return self.availableLanguageModel()
    }

    func availableModel() -> SystemLanguageModel.Availability {
        model.availability
    }

    func calculateHydratation() {
        var hidrationMininumRecommended = 0.0
        var hidrationMaximumRecommended = 0.0

        switch flourType {
        case .wheat:
            hidrationMininumRecommended = 60.0
            hidrationMaximumRecommended = 75.0
        case .wholewheat:
            hidrationMininumRecommended = 65.0
            hidrationMaximumRecommended = 85.0
        case .rye:
            hidrationMininumRecommended = 75.0
            hidrationMaximumRecommended = 100.0
        case .spelt:
            hidrationMininumRecommended = 65.0
            hidrationMaximumRecommended = 80.0
        case .corn:
            hidrationMininumRecommended = 70.0
            hidrationMaximumRecommended = 78.0
        }
        print("hidratacion minima: \(hidrationMininumRecommended)")
        print("hidratacion minima: \(hidrationMaximumRecommended)")

        let hydration = (Double(water) / Double(flourQuantity)) * 100

        print("La hidratación es \(hydration)")
        let isHidrated =
            (hidrationMininumRecommended...hidrationMaximumRecommended)
            .contains(hydration)

        if !isHidrated {
            Self.log.notice(
                "La hidratación no es la mas aconsejable para esta combinación"
            )
            self.alertHydrationNotPermmited =
                "La hidratación no es la más adecuada para la \(flourType.displayName)"
            self.hydrationNotPermitted = true
            return
        }

        hydrationNotPermitted = false

        // Parámetros de horneado. Fundamentado en Modernist Cuisine,
        // ThermoWorks, Wordloaf y King Arthur. Aquí la hidratación se usa en
        // FRACCIÓN (no en porcentaje).
        let hydrationFraction = Double(water) / Double(flourQuantity)

        // Por harina: (temp. horno base °C, factor de densidad, temp. interna °C)
        let baking: (oven: Double, density: Double, coreTemp: Int) =
            switch flourType {
            case .wheat: (230, 1.00, 96)
            case .wholewheat: (220, 1.10, 96)
            case .rye: (220, 1.15, 97)
            case .spelt: (215, 1.05, 95)
            case .corn: (200, 1.10, 90)
            }

        // Temperatura del horno: ajuste suave centrado en el punto medio del
        // rango de hidratación de la harina (más húmeda → un poco más calor).
        let midHydration =
            (hidrationMininumRecommended + hidrationMaximumRecommended) / 2
            / 100
        let tempAdjust = (hydrationFraction - midHydration) * 20
        temperature = min(
            250,
            max(190, Int((baking.oven + tempAdjust).rounded()))
        )

        // Tiempo de horneado: lo determina el PESO de la pieza, modulado por
        // hidratación, densidad de la harina y temperatura del horno.
        let doughWeight = Double(flourQuantity + water + yeast)
        var bakeTime = 15.0 + (doughWeight / 100) * 3.5
        bakeTime *= (1 + (hydrationFraction - 0.65) * 0.5)  // +húmeda → +tiempo
        bakeTime *= baking.density  // integral/centeno densos → +tiempo
        bakeTime *= (230 / Double(temperature))  // +caliente → -tiempo
        time = min(75, max(18, Int(bakeTime.rounded())))

        // Criterio real de cocción (ThermoWorks/Wordloaf): temperatura en el
        // centro de la miga, más fiable que el tiempo.
        internalTemperature = baking.coreTemp

        print(
            "Horno: \(temperature) °C · Tiempo: \(time) min · Temp. interna objetivo: \(internalTemperature) °C"
        )
    }

    private func resetIngredients() {
        self.flourType = .wheat
        self.flourQuantity = 125
        self.yeast = 5
        self.water = 125
    }

    func verifyHidration() {
        calculateHydratation()
        if hydrationNotPermitted {
            showHidrationAlert = true
        }
    }

    private func save() {
        guard let modelContext else { return }
        let ingredients = BreadUpIngredients(
            id: UUID(),
            water: water,
            flourTypeString: flourType.name,
            flourQuantity: flourQuantity,
            yeast: yeast,
            createdAt: selectedDate
        )

        let calculateBread = BreadUpCalculate(recipe: recipeTitle)

        recipeSteps.enumerated().forEach { index, recipeStep in
            calculateBread.steps.append(
                BreadUpStepRecipe(
                    order: index,
                    title: recipeStep.titulo,
                    descripcion: recipeStep.descripcion
                )
            )
        }
        ingredients.calculateBread = calculateBread

        modelContext.insert(ingredients)

        if modelContext.hasChanges {
            try? modelContext.save()
        }

        resetIngredients()

        Task {
            await saveIndex(recipe: ingredients)
        }
    }

    private func saveIndex(recipe: BreadUpIngredients) async {
        try? await self.recipeIndexer.index(recipe: recipe)
    }
    func delete(recipe: BreadUpIngredients) async throws {
        try? await RecipeBreadSpotlightIndexer.delete(recipe: recipe)
    }

    private func calculateRecipe() async {
        guard availableLanguageModel() else {
            self.alert = "No está disponible el modelo del lenguaje"
            Self.log.notice("Modelo de lenguaje no disponible")
            return
        }
        try? await self.generateRecipeBread()  // se traga cualquier throw, prevenirlo
    }

    private func cleanContextWindow() {
        session = LanguageModelSession(model: model, instructions: instructions)
        session.prewarm()
        //      session.logFeedbackAttachment(sentiment: .)
    }
    
    func checkAlreadyExists() {
        // Si ya existe una receta con estos ingredientes y fecha, avisamos sin
        // entrar en la pantalla de generación (evita mostrarla vacía).
        if recipeAlreadyExists() {
            Self.log.notice("Generación cancelada: la receta ya existe")
            hasDuplicateError = true
            return
        }
    }
    
    func buttonSave() {
        // Si ya existe una receta con estos ingredientes y fecha, avisamos sin
        // entrar en la pantalla de generación (evita mostrarla vacía).
        if recipeAlreadyExists() {
            // Self.log.notice("Generación cancelada: la receta ya existe")
            Self.log.notice("No podemos guardar: la receta ya existe")
            hasDuplicateError = true
            return
        }
        save()
        backToRecipeList()
    }

    func navigateToGenerateView() async {
        self.calculateHydratation()
        guard !hydrationNotPermitted else { return }  // se queda en RecipeDetailView con el alert

        path.append(.generate)
        cleanContextWindow()
        await calculateRecipe()
    }

    func backToRecipeList() {//private
        path.removeAll()
    }

    // Reintenta la generación sin volver a navegar (ya estamos en la vista de generación).
    func retryGeneration() async {
        cleanContextWindow()
        await calculateRecipe()
    }

    /// Devuelve los títulos de todas las recetas ya persistidas.
    ///
    /// Consultamos `BreadUpCalculate` directamente (es la entidad que guarda
    /// `recipe`) en lugar de partir de `BreadUpIngredients` y navegar la
    /// relación: así evitamos faultar los ingredientes para llegar al título.
    /// Descartamos los `nil` con `compactMap`, porque `recipe` es `String?`
    /// mientras la receta no se ha generado.
    private func allNamesRecipes() -> [String] {
        guard let modelContext else { return [] }

        let descriptor = FetchDescriptor<BreadUpCalculate>()
        let calculations = (try? modelContext.fetch(descriptor)) ?? []

        return calculations.compactMap(\.recipe)
    }

    private func generateRecipeBread() async throws {
        isLoading = true
        hasGenerationError = false
        receivedTotalInformationAboutRecipe = false
        recipeBreadSequence = nil
        recipeTitle = ""
        recipeSteps = []
        defer { isLoading = false }

        let namesRecipes = allNamesRecipes()
        
        var titleSection = """
        INSTRUCCIONES PARA EL TÍTULO (obligatorias):
        - Inventa un nombre original y evocador en español, de 4-5 palabras como máximo.
        - NO nombres la receta por el tipo de harina ni por los ingredientes: no uses la palabra "\(flourType.rawValue)" ni "harina", y evita fórmulas como "Pan de \(flourType.rawValue)".
        - Evoca una imagen, una sensación o un lugar (aroma, hogar, campo, tradición…).
        """
        if !namesRecipes.isEmpty {
            let list = namesRecipes.map { "  - \($0)" }.joined(separator: "\n")
            titleSection += "\n\n" + """
            Además, el título DEBE SER DISTINTO en concepto y palabras a estos, que ya existen (no los repitas ni reutilices sus palabras):
            \(list)
            """
        }

        do {
            let prompt =
                """
                    Crea una receta de pan casero usando estos ingredientes/cantidades:
                    - Agua: \(water) mililitros
                    - Harina de \(flourType.rawValue): \(flourQuantity) gramos
                    - Levadura fresca de panaderia: \(yeast) gramos.

                Condiciones de horneado (oriéntate por ellas, no las contradigas):
                    - Temperatura del horno \(temperature) °C
                    - Tiempo aproximado  en el horno: \(time) minutos (es ORIENTATIVO, varía según el horno)
                    - Punto de cocción: el pan estará listo cuando el centro de la miga alcanze \(internalTemperature) °C y el color de la corteza, no sólo por el reloj.
                """
                        
//            El título que has de generar para la receta de pan debe ser un nombre divertido, original, diferente y sugerente para el usuario y \
//            MUY IMPORTANTE: DO NOT repetir titulo que ya esté en esta lista: \(namesRecipes.joined(separator: ", "))
            let promptFinal = prompt + "\n\n" + titleSection
            print("prompt is \(promptFinal)")
            
            let stream = session.streamResponse(
                to: promptFinal,
                generating: BreadRecipe.self,
                options: options
            )
            for try await partial in stream {
                self.recipeBreadSequence = partial
            }
            self.recipeTitle = recipeBreadSequence?.content.title ?? ""
            self.recipeSteps = (recipeBreadSequence?.content.pasos ?? [])
                .compactMap { step in
                    guard let titulo = step.titulo,
                        let descripcion = step.descripcion
                    else { return nil }
                    return RecipeStep(titulo: titulo, descripcion: descripcion)
                }
            receivedTotalInformationAboutRecipe = true
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize(
            let content
        ) {
            session.logFeedbackAttachment(sentiment: .negative)
            Self.log.error(
                "Context window excedido: \(content.debugDescription, privacy: .public)"
            )
            self.alert = "Se ha excedido el contexto del tamaño de la ventana"
            hasGenerationError = true
            showConditionsRecipe()
        } catch LanguageModelSession.GenerationError.guardrailViolation(
            let content
        ) {
            session.logFeedbackAttachment(sentiment: .negative)
            Self.log.error(
                "Bloqueado por guardrails: \(content.debugDescription, privacy: .public)"
            )
            self.alert = "No podemos responder a dicha petición de receta"
            hasGenerationError = true
            showConditionsRecipe()
        } catch LanguageModelSession.GenerationError.assetsUnavailable(
            let content
        ) {
            session.logFeedbackAttachment(sentiment: .negative)
            Self.log.error(
                "Assets del modelo no disponibles: \(content.debugDescription, privacy: .public)"
            )
            self.alert = "Los assets del modelo no están disponible"
            hasGenerationError = true
            showConditionsRecipe()
        } catch {
            session.logFeedbackAttachment(sentiment: .negative)
            showConditionsRecipe()
            if containsSafetyAssetFailure(error) {
                Self.log.error(
                    "Assets del clasificador de seguridad ausentes o corruptos"
                )
                self.alert =
                    "Los modelos de Apple Intelligence están actualizándose en tu dispositivo. Reintenta en unos minutos."
            } else {
                Self.log.error(
                    "Error de generación: \(String(describing: error), privacy: .public)"
                )
                self.alert =
                    "Por algún motivo desconocido, no podemos atender su petición."
            }
            hasGenerationError = true
        }
    }

    private func showConditionsRecipe() {
        Self.log.error("Tipo de harina \(self.flourType.rawValue)")
        Self.log.error("Cantidad de harina \(self.flourQuantity)")
        Self.log.error("Cantidad de agua \(self.water)")
        Self.log.error("Levadura \(self.yeast)")
        Self.log.error("Temperatura del horno \(self.temperature) °C")
        Self.log.error("Tiempo en el horno \(self.time)")
        Self.log.error("Punto de cocción \(self.internalTemperature)")
    }

    /// `true` si ya hay una receta persistida con los mismos ingredientes de
    /// entrada (tipo y cantidad de harina, levadura) y el mismo día de elaboración.
    /// El título no entra en la comparación porque aún no se ha generado.
    ///
    /// Filtramos en la base de datos por los enteros (que son queryables) y
    /// afinamos en memoria el tipo de harina (enum `Codable`) y el día, porque
    /// esos no se comparan de forma fiable dentro de un `#Predicate`.
    private func recipeAlreadyExists() -> Bool {
        guard let modelContext else { return false }
        
        //let flourTypeName = flourType.name

        print("selectedDate: \(selectedDate.formatted(.dateTime))")
        print("recipeTitle: \(recipeTitle)")
        
        // Swift Data NO ES capaz de entrar a las propiedades una instancia, hay que sacar los valores antes
        let descriptor = FetchDescriptor<BreadUpIngredients>(
            predicate: #Predicate {
                // $0.created == selectedDate
                //&&
                //$0.created?.formatted(.dateTime).elementsEqual(selectedDate.formatted(.dateTime))
                //$0.created?.formatted(.dateTime) == selectedDate.formatted(.dateTime)
                
                // &&
                $0.calculateBread?.recipe == recipeTitle // "Pan del Campo Sereno"
                
                //$0.flourQuantity == flourQuantity
                //    && $0.yeast == yeast
                //    && $0.water == water
                //    && $0.flourTypeString == flourTypeName
            }
        )

        let candidates = try? modelContext.fetch(descriptor)

        return (candidates?.count != 0) ? true : false
    }

    private func containsSafetyAssetFailure(_ error: Error) -> Bool {
        let ns = error as NSError

        if ns.domain == "com.apple.SensitiveContentAnalysisML" { return true }

        // Algunos errores meten varios underlying en esta clave (no estándar en NSError API).
        if let multiple = ns.userInfo[NSMultipleUnderlyingErrorsKey]
            as? [Error],
            multiple.contains(where: { containsSafetyAssetFailure($0) })
        {
            return true
        }
        // El underlying "clásico".
        if let underlying = ns.userInfo[NSUnderlyingErrorKey] as? Error,
            containsSafetyAssetFailure(underlying)
        {
            return true
        }
        return false
    }

    /// Recorre la jerarquía de NSError subyacentes hasta la raíz.
    private static func dump(_ error: Error) {
        var current: NSError? = error as NSError
        var level = 0
        while let ns = current {
            log.error(
                """
                   [\(level)] domain=\(ns.domain, privacy: .public) \
                code=\(ns.code) desc=\(ns.localizedDescription, privacy: .public)
                """
            )
            current = ns.userInfo[NSUnderlyingErrorKey] as? NSError
            level += 1
        }
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
