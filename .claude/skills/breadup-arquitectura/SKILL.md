---
name: breadup-arquitectura
description: Referencia detallada de la arquitectura de BreadUp (persistencia SwiftData, generación con FoundationModels, vistas, integración con el sistema). Consultar al tocar código de persistencia/schema, BreadCalculatorVM, Model.swift/Tools.swift, las vistas de RecipeDetailView/RecipeSavedDetailView, o AppEntity/Intents/Spotlight. Migrado desde CLAUDE.md el 2026-08-25 para no cargarlo en cada sesión.
---

# Arquitectura de BreadUp

Flujo de capas: **SwiftData (schema/migración) → ViewModel (`@Observable`) → Views (SwiftUI)**, con FoundationModels como servicio de generación inyectado en el ViewModel.

### Persistencia (`BreadUp/SwiftData/`)
- `BreadUpApp.swift`: `AppModelStore.shared` es un `ModelContainer` `@MainActor` único, construido con `BreadUpMigrationPlan`. Se inyecta en la escena con `.modelContainer(...)`.
- Esquema **versionado**: `BreadUpSchemaV1` → `BreadUpSchemaV2` → `BreadUpSchemaV3` → `BreadUpSchemaV4` → `BreadUpSchemaV5` (`VersionedSchema`). `BreadUpMigrationPlan` encadena las migraciones: V1→V2 es `.custom` (añade el campo `created`, con backfill a `.now` en `didMigrate`); V2→V3, V3→V4 y V4→V5 son `.lightweight` (V2→V3 añade la entidad `StepRecipe` y su relación 1-N con `CalculateBread`; V3→V4 añade `isFavorite: Bool` a `Ingredients` con default `false`; V4→V5 añade `shapeString: String`/`pieceWeight: Int` a `Ingredients`, forma y peso de la pieza).
- **Usa siempre los typealias** `BreadUpIngredients` (= `BreadUpSchemaV5.Ingredients`), `BreadUpCalculate` (= `BreadUpSchemaV5.CalculateBread`) y `BreadUpStepRecipe` (= `BreadUpSchemaV5.StepRecipe`), definidos en `BreadUpMigrationPlan.swift`. Así el resto del código no se acopla a una versión concreta del schema. Al introducir cambios de modelo, crea una nueva `VersionedSchema` + stage de migración y reapunta los typealias; no edites un schema versionado ya migrado.
- **Gotcha de simulador**: si tras compilar con una versión de schema nueva el simulador lanza `NSCocoaErrorDomain Code=134504 "Cannot use staged migration with an unknown model version"`, normalmente no es un bug del plan de migración — es un store obsoleto en el simulador, de una instalación anterior, cuya versión no coincide con ninguna `VersionedSchema` declarada. La solución no es tocar código: desinstalar la app del simulador (`xcrun simctl uninstall booted com.josemanuel.lezcano.BreadUp` o borrado manual del icono) y volver a compilar/ejecutar para que cree el store limpio en la versión actual.
- Modelos: `Ingredients` (water/flourType/flourQuantity/yeast/created/isFavorite/shape/pieceWeight) tiene relación `.cascade` con `CalculateBread` (que guarda `recipe: String?` y una relación 1-N `.cascade` con `StepRecipe`, sus pasos).
- `FlourType` y `BreadShape` (ambos en `BreadUpMigrationPlan.swift`) son los enums de harina y forma de la pieza, con `displayName` en español; son los tipos usados por la UI. Persisten como `Codable`.

### Generación con FoundationModels (`BreadUp/Model/` + `ViewModel/`)
- **Ruta real, distinta de lo que sugieren los nombres de los tipos**: el código vive en `BreadUp/Model/Model.swift` y `BreadUp/Model/Tools.swift` (no existe `FMFBusiness/`). Las cabeceras de ambos ficheros aún dicen `Generable.swift`/`Tooling.swift` — nombres antiguos, sin actualizar tras un renombrado; los tipos que definen se siguen llamando así en el texto de abajo por claridad, pero al buscar el fichero usa el nombre real.
- `BreadCalculatorVM` (`@Observable @MainActor`): mantiene el estado del formulario, posee una `LanguageModelSession` con instrucciones de "maestro panadero", y expone la generación de recetas vía `generateRecipeBread()` — guided generation con streaming (`session.streamResponse(to:generating: BreadRecipe.self, options:)`). `prewarm()` se llama antes de generar.
- `Model.swift`: `BreadRecipe` (`@Generable`) tiene un campo `pasos: [RecipeStep]` con `.minimumCount(6), .maximumCount(9)` (rango, **no** un conteo fijo). `RecipeStep` (`titulo`/`descripcion`) es un struct **distinto** del `BreadUpStepRecipe` de SwiftData — no confundirlos, comparten nombre corto pero no están relacionados. No existe ningún ejemplo tipo `exampleRecipeBread` inyectado en el prompt; solo quedan constantes sueltas sin usar (`RecipeStep.example`, `.firstStep`…`.tenStep`).
- `Tools.swift`: define `GetBreadRecipeTool` (`Tool`, FoundationModels tool-calling) con `BreadArguments` `@Generable`, pero **está desconectado de la sesión activa** — en `BreadCalculatorVM.initVM()` la inicialización con `tools: [GetBreadRecipeTool()]` está comentada. La generación real es guided generation directa, sin tool-calling.
- `save()` del VM construye `BreadUpIngredients` + `BreadUpCalculate` y los inserta en el `ModelContext`.

### Vistas (`BreadUp/View/`)
- `ContentView` → `NavigationStack` → `RecipeListView` (lista con `@Query` de `BreadUpIngredients`, borrado por swipe) → `RecipeDetailView` (formulario con sliders, botón "Generar receta" condicionado a `model.availability`, guardado) y `RecipeSavedDetailView` (detalle de receta guardada). `StepView`/`StepCard`/`StepsBreadView` renderizan pasos.
- El proyecto tiene configuradas las Localizations **Spanish** (recién añadida) y **English** (ya existía previamente). Las cadenas de UI en el código siguen escritas en español.

### Integración con el sistema (`BreadUp/AppEntity/`) — WIP
- `RecipeBreadEntity` (`AppEntity` + `IndexedEntity`), `RecipeBreadIntents` (`CreateRecipeBreadIntent` + `BreadRecipeShortcuts`) y `RecipeBreadSpotlightIndexer` (CoreSpotlight). Mayormente esqueleto: las queries devuelven `[]` y el indexado usa placeholders. Punto de partida para Siri/Shortcuts/Spotlight, no funcional aún.

### Playground (`BreadUp/Playground/`)
Experimentos sueltos con FoundationModels (`#Playground`), fuera del flujo de la app.
