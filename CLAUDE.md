# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Qué es BreadUp

App iOS de recetas de pan que usa **FoundationModels** (modelo on-device de Apple Intelligence) para generar recetas a partir de los ingredientes que el usuario configura (tipo de harina, cantidades de harina/agua/levadura, fecha). Las recetas y sus ingredientes se persisten con **SwiftData**.

Es un proyecto exploratorio/de aprendizaje: hay abundante código comentado, ficheros stub (`CloudKit/Cloudkit.swift`, `basura.swift` están vacíos) y módulos a medio implementar (AppEntity/Intents/Spotlight devuelven `[]`). No asumas que todo lo que existe está en uso por el flujo principal.

## Comandos

Build, arranque y tests van **exclusivamente** vía el MCP `xcode` (ver más abajo). No hay comandos de shell recomendados para este proyecto.

- Esquema único: `BreadUp`. Bundle id `com.josemanuel.lezcano.BreadUp`.
- **FoundationModels solo funciona en dispositivos con Apple Intelligence habilitado.** En simuladores/dispositivos no elegibles, `SystemLanguageModel.default.availability` será `.unavailable(...)` y la generación de recetas no se ejecuta (la UI lo refleja en `RecipeDetailView`).

### MCP `xcode` (obligatorio, sin excepciones)

El `.xcodeproj` **no se toca nunca internamente a través del shell** (`xcodebuild`, edición manual del `.pbxproj`, o `Read`/`Write`/`Edit`/`Grep` estándar sobre `BreadUp/**/*.swift` u otros ficheros del target). Usa siempre las herramientas del MCP `xcode` (`XcodeRead`/`XcodeWrite`/`XcodeGrep`/`BuildProject`/`RunAllTests`/`RunSomeTests`/`RenderPreview`/`XcodeRM`…). Si por cualquier motivo excepcional fuera necesario recurrir al shell, **pide autorización expresa y justifica el motivo antes de hacerlo** — nunca por iniciativa propia, ni siquiera como fallback si el MCP está desconectado (en ese caso, informa y espera a que se reconecte). Ficheros fuera del proyecto (este `CLAUDE.md`, `.claude/`, `Docs/`, scripts) van por las herramientas estándar.

## Testing

- **Tests unitarios: solo Swift Testing** (`import Testing`, `@Test`, `#expect`) — target `BreadUpTests`. No uses XCTest para tests unitarios.
- **XCTest se reserva exclusivamente para UI Tests** — es la única herramienta disponible para ese propósito a mayo de 2026 (Swift Testing no cubre todavía UI testing).
- Ejecuta siempre los tests vía el MCP `xcode` (`RunAllTests`/`RunSomeTests`/`GetTestList`), nunca `xcodebuild test` en shell.

## Configuración de compilación crítica

El target impone reglas estrictas que hay que respetar en todo código nuevo:

- **Swift 6**, `SWIFT_STRICT_CONCURRENCY = complete`.
- **`SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated`** → el aislamiento por defecto NO es `@MainActor`. Anota `@MainActor` explícitamente donde toque UI/`ModelContext` en el hilo principal.
- **`SWIFT_TREAT_WARNINGS_AS_ERRORS = YES`** → cualquier warning rompe el build. No dejes imports/variables sin usar.
- Deployment target iOS 26. `SUPPORTED_PLATFORMS = iphoneos iphonesimulator macosx`.
- **Icono de la app: formato `.icon` (Icon Composer, norma de Xcode 26)**. Ya está configurado — no uses el formato clásico `.appiconset`/PNGs sueltos dentro de `Assets.xcassets` para el icono.

## Arquitectura

Flujo de capas: **SwiftData (schema/migración) → ViewModel (`@Observable`) → Views (SwiftUI)**, con FoundationModels como servicio de generación inyectado en el ViewModel.

### Persistencia (`BreadUp/SwiftData/`)
- `BreadUpApp.swift`: `AppModelStore.shared` es un `ModelContainer` `@MainActor` único, construido con `BreadUpMigrationPlan`. Se inyecta en la escena con `.modelContainer(...)`.
- Esquema **versionado**: `BreadUpSchemaV1` → `BreadUpSchemaV2` → `BreadUpSchemaV3` → `BreadUpSchemaV4` (`VersionedSchema`). `BreadUpMigrationPlan` encadena las migraciones: V1→V2 es `.custom` (añade el campo `created`, con backfill a `.now` en `didMigrate`); V2→V3 y V3→V4 son `.lightweight` (V2→V3 añade la entidad `StepRecipe` y su relación 1-N con `CalculateBread`; V3→V4 añade `isFavorite: Bool` a `Ingredients` con default `false`).
- **Usa siempre los typealias** `BreadUpIngredients` (= `BreadUpSchemaV4.Ingredients`), `BreadUpCalculate` (= `BreadUpSchemaV4.CalculateBread`) y `BreadUpStepRecipe` (= `BreadUpSchemaV4.StepRecipe`), definidos en `BreadUpMigrationPlan.swift`. Así el resto del código no se acopla a una versión concreta del schema. Al introducir cambios de modelo, crea una nueva `VersionedSchema` + stage de migración y reapunta los typealias; no edites un schema versionado ya migrado.
- Modelos: `Ingredients` (water/flourType/flourQuantity/yeast/created/isFavorite) tiene relación `.cascade` con `CalculateBread` (que guarda `recipe: String?` y una relación 1-N `.cascade` con `StepRecipe`, sus pasos).
- `FlourType` (en `BreadUpMigrationPlan.swift`) es el enum de harinas con `displayName` en español; es el tipo usado por la UI. Persiste como `Codable`.

### Generación con FoundationModels (`BreadUp/Model/` + `ViewModel/`)
- **Ruta real, distinta de lo que sugieren los nombres de los tipos**: el código vive en `BreadUp/Model/Model.swift` y `BreadUp/Model/Tools.swift` (no existe `FMFBusiness/`). Las cabeceras de ambos ficheros aún dicen `Generable.swift`/`Tooling.swift` — nombres antiguos, sin actualizar tras un renombrado; los tipos que definen se siguen llamando así en el texto de abajo por claridad, pero al buscar el fichero usa el nombre real.
- `BreadCalculatorVM` (`@Observable @MainActor`): mantiene el estado del formulario, posee una `LanguageModelSession` con instrucciones de "maestro panadero", y expone la generación de recetas vía `generateRecipeBread()` — guided generation con streaming (`session.streamResponse(to:generating: BreadRecipe.self, options:)`). `prewarm()` se llama antes de generar.
- `Model.swift`: `BreadRecipe` (`@Generable`) tiene un campo `pasos: [RecipeStep]` con `.minimumCount(6), .maximumCount(9)` (rango, **no** un conteo fijo). `RecipeStep` (`titulo`/`descripcion`) es un struct **distinto** del `BreadUpStepRecipe` de SwiftData (typealias de `BreadUpSchemaV4.StepRecipe`, persistencia) — no confundirlos, comparten nombre corto pero no están relacionados. No existe ningún ejemplo tipo `exampleRecipeBread` inyectado en el prompt; solo quedan constantes sueltas sin usar (`RecipeStep.example`, `.firstStep`…`.tenStep`).
- `Tools.swift`: define `GetBreadRecipeTool` (`Tool`, FoundationModels tool-calling) con `BreadArguments` `@Generable`, pero **está desconectado de la sesión activa** — en `BreadCalculatorVM.initVM()` la inicialización con `tools: [GetBreadRecipeTool()]` está comentada. La generación real es guided generation directa, sin tool-calling.
- `save()` del VM construye `BreadUpIngredients` + `BreadUpCalculate` y los inserta en el `ModelContext`.

### Vistas (`BreadUp/View/`)
- `ContentView` → `NavigationStack` → `RecipeListView` (lista con `@Query` de `BreadUpIngredients`, borrado por swipe) → `RecipeDetailView` (formulario con sliders, botón "Generar receta" condicionado a `model.availability`, guardado) y `RecipeSavedDetailView` (detalle de receta guardada). `StepView`/`StepCard`/`StepsBreadView` renderizan pasos.
- El proyecto tiene configuradas las Localizations **Spanish** (recién añadida) y **English** (ya existía previamente). Las cadenas de UI en el código siguen escritas en español.

### Integración con el sistema (`BreadUp/AppEntity/`) — WIP
- `RecipeBreadEntity` (`AppEntity` + `IndexedEntity`), `RecipeBreadIntents` (`CreateRecipeBreadIntent` + `BreadRecipeShortcuts`) y `RecipeBreadSpotlightIndexer` (CoreSpotlight). Mayormente esqueleto: las queries devuelven `[]` y el indexado usa placeholders. Punto de partida para Siri/Shortcuts/Spotlight, no funcional aún.

### Playground (`BreadUp/Playground/`)
Experimentos sueltos con FoundationModels (`#Playground`), fuera del flujo de la app.
