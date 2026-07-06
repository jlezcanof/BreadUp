# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Qué es BreadUp

App iOS de recetas de pan que usa **FoundationModels** (modelo on-device de Apple Intelligence) para generar recetas a partir de los ingredientes que el usuario configura (tipo de harina, cantidades de harina/agua/levadura, fecha). Las recetas y sus ingredientes se persisten con **SwiftData**.

Es un proyecto exploratorio/de aprendizaje: hay abundante código comentado, ficheros stub (`CloudKit/Cloudkit.swift`, `basura.swift` están vacíos) y módulos a medio implementar (AppEntity/Intents/Spotlight devuelven `[]`). No asumas que todo lo que existe está en uso por el flujo principal.

## Comandos

No hay aún ninguna target de tests. Build y arranque vía `xcodebuild` (o preferiblemente el MCP `xcode`, ver más abajo):

```bash
# Compilar para simulador iOS
xcodebuild -project BreadUp.xcodeproj -scheme BreadUp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Limpiar
xcodebuild -project BreadUp.xcodeproj -scheme BreadUp clean
```

- Esquema único: `BreadUp`. Bundle id `com.josemanuel.lezcano.BreadUp`.
- **FoundationModels solo funciona en dispositivos con Apple Intelligence habilitado.** En simuladores/dispositivos no elegibles, `SystemLanguageModel.default.availability` será `.unavailable(...)` y la generación de recetas no se ejecuta (la UI lo refleja en `RecipeDetailView`).

### MCP `xcode` (preferente)

Para cualquier fichero que pertenezca al `.xcodeproj` (todo `BreadUp/**/*.swift`), usa las herramientas del MCP `xcode` (`XcodeRead`/`XcodeWrite`/`XcodeGrep`/`BuildProject`/`RunAllTests`/`RenderPreview`…) en lugar de `xcodebuild` en Bash o de Read/Write/Grep. Ficheros fuera del proyecto (este `CLAUDE.md`, `.claude/`, scripts) van por las herramientas estándar.

## Configuración de compilación crítica

El target impone reglas estrictas que hay que respetar en todo código nuevo:

- **Swift 6**, `SWIFT_STRICT_CONCURRENCY = complete`.
- **`SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated`** → el aislamiento por defecto NO es `@MainActor`. Anota `@MainActor` explícitamente donde toque UI/`ModelContext` en el hilo principal.
- **`SWIFT_TREAT_WARNINGS_AS_ERRORS = YES`** → cualquier warning rompe el build. No dejes imports/variables sin usar.
- Deployment target iOS 26. `SUPPORTED_PLATFORMS = iphoneos iphonesimulator macosx`.

## Arquitectura

Flujo de capas: **SwiftData (schema/migración) → ViewModel (`@Observable`) → Views (SwiftUI)**, con FoundationModels como servicio de generación inyectado en el ViewModel.

### Persistencia (`BreadUp/SwiftData/`)
- `BreadUpApp.swift`: `AppModelStore.shared` es un `ModelContainer` `@MainActor` único, construido con `BreadUpMigrationPlan`. Se inyecta en la escena con `.modelContainer(...)`.
- Esquema **versionado**: `BreadUpSchemaV1` → `BreadUpSchemaV2` (`VersionedSchema`). `BreadUpMigrationPlan` define una migración `.custom` (V1→V2 añade el campo `created`).
- **Usa siempre los typealias** `BreadUpIngredients` (= `BreadUpSchemaV2.Ingredients`) y `BreadUpCalculate` (= `BreadUpSchemaV2.CalculateBread`), definidos en `BreadUpMigrationPlan.swift`. Así el resto del código no se acopla a una versión concreta del schema. Al introducir cambios de modelo, crea una nueva `VersionedSchema` + stage de migración y reapunta los typealias; no edites un schema versionado ya migrado.
- Modelos: `Ingredients` (water/flourType/flourQuantity/yeast/created) tiene relación `.cascade` con `CalculateBread` (que guarda `recipe: String?`).
- `FlourType` (en `BreadUpMigrationPlan.swift`) es el enum de harinas con `displayName` en español; es el tipo usado por la UI. Persiste como `Codable`.

### Generación con FoundationModels (`BreadUp/FMFBusiness/` + `ViewModel/`)
- `BreadCalculatorVM` (`@Observable @MainActor`): mantiene el estado del formulario, posee una `LanguageModelSession` con instrucciones de "maestro panadero" y la `GetBreadRecipeTool`, y expone la generación de recetas.
- Hay **tres estrategias de generación** implementadas en el VM; el punto de entrada `calculateRecipe()` usa la de **streaming** (`suggestSequenceBread`, `streamResponse(generating: BreadRecipe.self)`). Las otras dos (`generateRecipeBread` texto plano, `suggestRecipeBread` guided generation no-stream) quedan como alternativas. `prewarm()` se llama antes de generar.
- `Generable.swift`: `BreadRecipe` (`@Generable`, exactamente 8 `StepRecipe` vía `.count(8)`) y `StepRecipe` son el **schema de salida guiada** del modelo. Llevan `@Guide` y ejemplos (`exampleRecipeBread`) que se inyectan en el prompt.
- `Tooling.swift`: `GetBreadRecipeTool` implementa `Tool` (FoundationModels tool-calling) con `BreadArguments` `@Generable`.
- `save(context:)` del VM construye `BreadUpIngredients` + `BreadUpCalculate` y los inserta en el `ModelContext`.

### Vistas (`BreadUp/View/`)
- `ContentView` → `NavigationStack` → `RecipeListView` (lista con `@Query` de `BreadUpIngredients`, borrado por swipe) → `RecipeDetailView` (formulario con sliders, botón "Generar receta" condicionado a `model.availability`, guardado) y `RecipeSavedDetailView` (detalle de receta guardada). `StepView`/`StepCard`/`StepsBreadView` renderizan pasos.
- Todas las cadenas de UI están **en español, hardcodeadas** (no hay catálogo de localización `Localizable.xcstrings` todavía).

### Integración con el sistema (`BreadUp/AppEntity/`) — WIP
- `RecipeBreadEntity` (`AppEntity` + `IndexedEntity`), `RecipeBreadIntents` (`CreateRecipeBreadIntent` + `BreadRecipeShortcuts`) y `RecipeBreadSpotlightIndexer` (CoreSpotlight). Mayormente esqueleto: las queries devuelven `[]` y el indexado usa placeholders. Punto de partida para Siri/Shortcuts/Spotlight, no funcional aún.

### Playground (`BreadUp/Playground/`)
Experimentos sueltos con FoundationModels (`#Playground`), fuera del flujo de la app.
