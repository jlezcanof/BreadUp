//
//  BreadUpTests.swift
//  BreadUpTests
//
//  Created by Yomismista on 06/07/2026.
//

import Testing
import Foundation
import SwiftData
@testable import BreadUp

// MARK: - Fixtures (Sendable, para tests parametrizados)

/// Combinación harina/cantidad/agua para verificar el veredicto de hidratación.
struct HydrationBoundaryCase: Sendable {
    let flour: FlourType
    let flourQuantity: Int
    let water: Int
}

/// Combinación en el punto medio del rango de hidratación (donde el ajuste de
/// temperatura del horno es cero), con los valores esperados de temperatura de
/// horno base y temperatura interna objetivo por tipo de harina.
struct BakingProfileCase: Sendable {
    let flour: FlourType
    let flourQuantity: Int
    let water: Int
    let expectedOvenTemperature: Int
    let expectedCoreTemperature: Int
}

// MARK: - Dobles de test

/// Doble no-op de la costura `RecipeIndexing`. Neutraliza el efecto de sistema
/// fire-and-forget que `save()` dispara: no toca `CSSearchableIndex` (efecto de
/// sistema, prohibido en tests) y, al ignorar `recipe`, no accede a la instancia
/// `@Model` que el `ModelContext` en memoria destruye al resetearse (la causa
/// del crash que arrastraba a toda la suite).
///
@MainActor
private struct NoopRecipeIndexer: RecipeIndexing {
    func index(recipe: BreadUpIngredients) async throws {
        print("NoopRecipeIndexer.index")
    }
    func delete(recipe: BreadUpIngredients) async throws {
        print("Nooprecipeindexer.delete")
    }
}

@Suite("Bread Up Tests")
@MainActor
struct BreadUpTests {

    // MARK: - Helpers

    /// VM con los ingredientes de entrada ya configurados. No inyecta contexto:
    /// sirve para la lógica pura (`calculateHydratation`/`verifyHidration`).
    private func makeVM(
        flour: FlourType,
        flourQuantity: Int,
        water: Int,
        yeast: Int = 5
    ) -> BreadCalculatorVM {
        let vm = BreadCalculatorVM(recipeIndexer: NoopRecipeIndexer())
        vm.flourType = flour
        vm.flourQuantity = flourQuantity
        vm.water = water
        vm.yeast = yeast
        return vm
    }

    /// Contenedor SwiftData en memoria con el grafo completo del esquema V3.
    private func makeInMemoryContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: BreadUpIngredients.self,
            BreadUpCalculate.self,
            BreadUpStepRecipe.self,
            configurations: configuration
        )
    }

    /// VM con el `ModelContext` inyectado vía `initVM`, listo para persistir.
    /// Inyecta el doble no-op de indexado para que `save()` no dispare el efecto
    /// de sistema fire-and-forget sobre el modelo en memoria.
    private func makeConfiguredVM(context: ModelContext) -> BreadCalculatorVM {
        let vm = BreadCalculatorVM(recipeIndexer: NoopRecipeIndexer())
        vm.initVM(modelContext: context)
        return vm
    }

    // MARK: - Hidratación

    /// Bordes inclusivos de cada rango de hidratación (mínimo y máximo exactos):
    /// dentro del rango, la combinación es válida.
    @Test(
        "Hidratación en el borde inclusivo del rango → permitida",
        arguments: [
            HydrationBoundaryCase(flour: .wheat, flourQuantity: 100, water: 60),
            HydrationBoundaryCase(flour: .wheat, flourQuantity: 100, water: 75),
            HydrationBoundaryCase(flour: .wholewheat, flourQuantity: 100, water: 65),
            HydrationBoundaryCase(flour: .wholewheat, flourQuantity: 100, water: 85),
            HydrationBoundaryCase(flour: .rye, flourQuantity: 100, water: 75),
            HydrationBoundaryCase(flour: .rye, flourQuantity: 100, water: 100),
            HydrationBoundaryCase(flour: .spelt, flourQuantity: 100, water: 65),
            HydrationBoundaryCase(flour: .spelt, flourQuantity: 100, water: 80),
            HydrationBoundaryCase(flour: .corn, flourQuantity: 100, water: 70),
            HydrationBoundaryCase(flour: .corn, flourQuantity: 100, water: 78),
        ]
    )
    func hydrationWithinInclusiveRangeIsPermitted(_ testCase: HydrationBoundaryCase) {
        let vm = makeVM(
            flour: testCase.flour,
            flourQuantity: testCase.flourQuantity,
            water: testCase.water
        )

        vm.calculateHydratation()

        #expect(vm.hydrationNotPermitted == false)
        #expect(vm.alertHydrationNotPermmited.isEmpty)
    }

    /// Un punto porcentual por debajo del mínimo y por encima del máximo de cada
    /// rango: la combinación es inválida y la guarda temprana deja intactos los
    /// parámetros de horneado (siguen en 0, su valor inicial).
    @Test(
        "Hidratación fuera del rango → no permitida y sin tocar el horneado",
        arguments: [
            HydrationBoundaryCase(flour: .wheat, flourQuantity: 100, water: 59),
            HydrationBoundaryCase(flour: .wheat, flourQuantity: 100, water: 76),
            HydrationBoundaryCase(flour: .wholewheat, flourQuantity: 100, water: 64),
            HydrationBoundaryCase(flour: .wholewheat, flourQuantity: 100, water: 86),
            HydrationBoundaryCase(flour: .rye, flourQuantity: 100, water: 74),
            HydrationBoundaryCase(flour: .rye, flourQuantity: 100, water: 101),
            HydrationBoundaryCase(flour: .spelt, flourQuantity: 100, water: 64),
            HydrationBoundaryCase(flour: .spelt, flourQuantity: 100, water: 81),
            HydrationBoundaryCase(flour: .corn, flourQuantity: 100, water: 69),
            HydrationBoundaryCase(flour: .corn, flourQuantity: 100, water: 79),
        ]
    )
    func hydrationOutsideRangeIsNotPermitted(_ testCase: HydrationBoundaryCase) {
        let vm = makeVM(
            flour: testCase.flour,
            flourQuantity: testCase.flourQuantity,
            water: testCase.water
        )

        vm.calculateHydratation()

        #expect(vm.hydrationNotPermitted == true)
        #expect(!vm.alertHydrationNotPermmited.isEmpty)
        // Guarda temprana: la combinación inválida no calcula horneado.
        #expect(vm.temperature == 0)
        #expect(vm.time == 0)
        #expect(vm.internalTemperature == 0)
    }

    // MARK: - Horneado (oráculo calculado a mano)

    /// Oráculo calculado a mano (trigo, 500 g harina / 350 ml agua = 70%, 10 g
    /// levadura):
    ///   fracción = 0.7 · punto medio = 0.675 · ajuste = (0.7 − 0.675)·20 ≈ 0.5
    ///   temperatura = round(230 + 0.5) = 231 °C
    ///   peso = 860 → base = 15 + 8.6·3.5 = 45.1
    ///   45.1 · (1 + (0.7−0.65)·0.5) · 1.00 · (230/231) ≈ 46.03 → 46 min
    ///   temperatura interna del trigo = 96 °C
    @Test("Oráculo horneado: trigo al 70% → 231 °C, 46 min, 96 °C internos")
    func bakingParametersForWheatAt70PercentMatchManualOracle() {
        let vm = makeVM(flour: .wheat, flourQuantity: 500, water: 350, yeast: 10)

        vm.calculateHydratation()

        #expect(vm.hydrationNotPermitted == false)
        #expect(vm.temperature == 231)
        #expect(vm.time == 46)
        #expect(vm.internalTemperature == 96)
    }

    /// Clamp superior del tiempo (trigo, 1000 g / 750 ml = 75%, 20 g): la fórmula
    /// da ≈ 80 minutos y se recorta al máximo de 75.
    @Test("Tiempo de horneado se recorta al máximo de 75 minutos")
    func bakeTimeClampsToUpperBound() {
        let vm = makeVM(flour: .wheat, flourQuantity: 1000, water: 750, yeast: 20)

        vm.calculateHydratation()

        #expect(vm.hydrationNotPermitted == false)
        #expect(vm.time == 75)
    }

    /// En el punto medio del rango de hidratación de cada harina el ajuste de
    /// temperatura es exactamente 0, así que la temperatura del horno es la base
    /// de esa harina. La temperatura interna objetivo depende sólo del tipo.
    ///   trigo: base 230 / interna 96   ·   trigo integral: 220 / 96
    ///   centeno: 220 / 97   ·   espelta: 215 / 95   ·   maíz: 200 / 90
    @Test(
        "Temperatura de horno base y temperatura interna por tipo de harina",
        arguments: [
            BakingProfileCase(flour: .wheat, flourQuantity: 200, water: 135, expectedOvenTemperature: 230, expectedCoreTemperature: 96),
            BakingProfileCase(flour: .wholewheat, flourQuantity: 100, water: 75, expectedOvenTemperature: 220, expectedCoreTemperature: 96),
            BakingProfileCase(flour: .rye, flourQuantity: 200, water: 175, expectedOvenTemperature: 220, expectedCoreTemperature: 97),
            BakingProfileCase(flour: .spelt, flourQuantity: 200, water: 145, expectedOvenTemperature: 215, expectedCoreTemperature: 95),
            BakingProfileCase(flour: .corn, flourQuantity: 100, water: 74, expectedOvenTemperature: 200, expectedCoreTemperature: 90),
        ]
    )
    func ovenAndCoreTemperatureAtMidHydration(_ testCase: BakingProfileCase) {
        let vm = makeVM(
            flour: testCase.flour,
            flourQuantity: testCase.flourQuantity,
            water: testCase.water
        )

        vm.calculateHydratation()

        #expect(vm.hydrationNotPermitted == false)
        #expect(vm.temperature == testCase.expectedOvenTemperature)
        #expect(vm.internalTemperature == testCase.expectedCoreTemperature)
    }

    // MARK: - verifyHidration

    @Test("verifyHidration: combinación válida no muestra la alerta")
    func verifyHidrationValidCombinationDoesNotShowAlert() {
        let vm = makeVM(flour: .wheat, flourQuantity: 500, water: 350)

        vm.verifyHidration()

        #expect(vm.hydrationNotPermitted == false)
        #expect(vm.showHidrationAlert == false)
    }

    @Test("verifyHidration: combinación inválida activa la alerta")
    func verifyHidrationInvalidCombinationShowsAlert() {
        let vm = makeVM(flour: .wheat, flourQuantity: 125, water: 125)

        vm.verifyHidration()

        #expect(vm.hydrationNotPermitted == true)
        #expect(vm.showHidrationAlert == true)
    }

    // MARK: - Persistencia

    @Test("save persiste ingredientes, título de receta y pasos ordenados")
    func savePersistsIngredientsRecipeAndSteps() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let vm = makeConfiguredVM(context: context)

        let expectedDate = Date(timeIntervalSince1970: 1_700_000_000)
        vm.flourType = .rye
        vm.flourQuantity = 400
        vm.water = 320
        vm.yeast = 8
        vm.selectedDate = expectedDate
        vm.recipeTitle = "Pan de centeno de prueba"
        vm.recipeSteps = [
            RecipeStep(titulo: "Mezclar", descripcion: "Mezcla la harina con el agua."),
            RecipeStep(titulo: "Amasar", descripcion: "Amasa durante diez minutos."),
            RecipeStep(titulo: "Hornear", descripcion: "Hornea el pan."),
        ]

        //vm.save()
        vm.buttonSave()
        
        let stored = try context.fetch(FetchDescriptor<BreadUpIngredients>())
        #expect(stored.count == 1)

        let saved = try #require(stored.first)
        #expect(saved.water == 320)
        #expect(saved.flourQuantity == 400)
        #expect(saved.yeast == 8)
        #expect(saved.flourType == .rye)

        let created = try #require(saved.created)
        #expect(created == expectedDate)

        let calculateBread = try #require(saved.calculateBread)
        #expect(calculateBread.recipe == "Pan de centeno de prueba")

        let steps = calculateBread.steps.sorted { $0.order < $1.order }
        #expect(steps.map(\.order) == [0, 1, 2])
        #expect(steps.map(\.title) == ["Mezclar", "Amasar", "Hornear"])
        #expect(steps.map(\.descripcion) == [
            "Mezcla la harina con el agua.",
            "Amasa durante diez minutos.",
            "Hornea el pan.",
        ])
    }

    @Test("save restablece los ingredientes a sus valores por defecto")
    func saveResetsIngredientsToDefaults() throws {
        let container = try makeInMemoryContainer()
        let vm = makeConfiguredVM(context: container.mainContext)
        
        vm.flourType = .rye
        vm.flourQuantity = 400
        vm.water = 320
        vm.yeast = 8

        //vm.save()
        vm.buttonSave()

        #expect(vm.flourType == .wheat)
        #expect(vm.flourQuantity == 125)
        #expect(vm.yeast == 5)
        #expect(vm.water == 125)
    }

    // MARK: - Navegación (sólo ramas de retorno temprano, sin FoundationModels)

    @Test("GenerateBreadRecipeView: receta duplicada avisa y no navega")
    func generateBreadRecipeViewDuplicateSetsErrorAndDoesNotNavigate() async throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        
        let recipeTitle = "Pan del siglo XX"
        let firstBread = BreadUpIngredients(
            id: UUID(),
            water: 350,
            flourTypeString: "wheat",
            flourQuantity: 500,
            yeast: 10,
            createdAt: nil
        )
        
        let calculateBread = BreadUpCalculate(recipe: recipeTitle)
        firstBread.calculateBread = calculateBread
        
        context.insert(firstBread)
        try context.save()

        let vm = makeConfiguredVM(context: context)
        // Mismos ingredientes que la receta ya persistida.
        vm.flourType = .wheat
        vm.flourQuantity = 500
        vm.water = 350
        vm.yeast = 10
        vm.recipeTitle = recipeTitle

        vm.buttonSave()

        #expect(vm.hasDuplicateError == true)
        #expect(vm.path.isEmpty)
    }

    @Test("navigateToGenerateView: hidratación inválida no navega")
    func navigateToGenerateViewInvalidHydrationDoesNotNavigate() async throws {
        let container = try makeInMemoryContainer()
        let vm = makeConfiguredVM(context: container.mainContext)
        // 125 ml / 125 g = 100% de hidratación, inválida para el trigo (60–75%).
        vm.flourType = .wheat
        vm.flourQuantity = 125
        vm.water = 125
        vm.yeast = 5

        await vm.navigateToGenerateView()

        #expect(vm.path.isEmpty)
        #expect(vm.hydrationNotPermitted == true)
        #expect(vm.hasDuplicateError == false)
    }

}
