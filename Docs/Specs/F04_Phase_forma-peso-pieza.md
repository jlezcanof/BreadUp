# Forma y peso de la pieza como input de generación

**Prioridad:** Normal

**Estado:** Implementado y cerrado (2026-08-07). Ver "Estado final" al fondo de este documento.

## Contexto

Según todas las fuentes recogidas (`Docs/SOURCES-INFO.md`), el factor que realmente determina la temperatura y el tiempo de horno es la forma y el tamaño/peso de la pieza (masa magra en hogaza/baguette/molde a 230–250 °C; el tiempo depende del peso) — no la cantidad de harina/agua/levadura que hoy configura el usuario. `RecipeDetailView` nunca pregunta esto, por lo que el modelo genera instrucciones de horno "a ciegas" respecto al factor más determinante según la ciencia panadera.

## Propuesta

- Nuevo enum `BreadShape` (hogaza, baguette, molde), análogo a `FlourType`, con `displayName` en español, definido junto a `FlourType` en `BreadUpMigrationPlan.swift`.
- Nueva `Section` "Forma de la pieza" en `RecipeDetailView`: `Picker` de `BreadShape` + peso aproximado de la pieza final, calculado automáticamente a partir de harina+agua+levadura (no editable directamente — ver "Estado final").
- `BreadCalculatorVM` incorpora `breadShape`/`pieceWeight` en las instrucciones/prompt de generación (`GetBreadRecipeTool`/`BreadArguments`).
- `Generable.swift` usa `@Guide` para que el modelo ajuste temperatura/tiempo de horno generados según la forma (230–250 °C para masa magra) y el peso de la pieza.
- Se persiste `shape: BreadShape` en `BreadUpIngredients` vía nueva `BreadUpSchemaV5` (o V6 si coincide en el tiempo con el diario de horneado), con migración `.lightweight` análoga a como V4 añadió `isFavorite`.

## Alcance

- `BreadUp/SwiftData/BreadUpMigrationPlan.swift` + nuevo `BreadUpSchemaV5.swift`: nuevo enum `BreadShape` + nueva versión de schema con el campo `shape`.
- `BreadUp/View/RecipeDetailView.swift`: nuevo `Picker`/control de peso.
- `BreadUp/Model/Tools.swift` (`BreadArguments`, hoy desconectado) y `BreadUp/Model/Model.swift` (`BreadRecipe`/`RecipeStep`): nuevos parámetros e instrucciones `@Guide` si aplica.
- `BreadUp/ViewModel/BreadCalculatorVM.swift`: nuevo estado de formulario, `calculateHydratation()`, prompt de generación, `save()`/`resetIngredients()`.

## Análisis técnico (tras exploración de código, 2026-08-06)

Nota de rutas: `BreadUp/FMFBusiness/` no existe — corregido arriba. Ver también `CLAUDE.md`, sección "Generación con FoundationModels", actualizada con el mismo hallazgo.

### 1. Persistencia — `BreadUpMigrationPlan.swift` + nuevo `BreadUpSchemaV5.swift`

Patrón a replicar, idéntico al de `FlourType` (mismo fichero):
```swift
enum BreadShape: String, CaseIterable, Identifiable, Codable {
    case hogaza = "Hogaza"
    case baguette = "Baguette"
    case molde = "Molde"

    var id: Self { self }

    var displayName: String {
        switch self {
        case .hogaza: return "Hogaza"
        case .baguette: return "Baguette"
        case .molde: return "Molde"
        }
    }

    var name: String {  // identificador canónico persistido, no el rawValue en español
        switch self {
        case .hogaza: return "hogaza"
        case .baguette: return "baguette"
        case .molde: return "molde"
        }
    }
}
```
`Ingredients` en V4 persiste el tipo de harina como `flourTypeString: String` (el `name` canónico) con una computed property `flourType` que traduce ambos sentidos — replicar igual: `shapeString: String` + computed `shape: BreadShape`.

**Dos inits a actualizar** en `Ingredients` (V5, copiado de V4 + campo nuevo): el designated (`flourTypeString:` → añadir `shapeString: String = "hogaza"`) y el convenience (`flourType:` → añadir `shape: BreadShape = .hogaza`).

**Migración V4→V5**: `.lightweight` puro (mismo patrón que V3→V4, que solo añadió `isFavorite: Bool = false`, sin closures), válido porque `shapeString` lleva default:
```swift
static let migrationV4toV5 = MigrationStage.lightweight(
    fromVersion: BreadUpSchemaV4.self, toVersion: BreadUpSchemaV5.self
)
```
Añadir `BreadUpSchemaV5.self` a `schemas`, `migrationV4toV5` a `stages`, y repuntar los 3 typealiases a V5.

**5 call sites que instancian `BreadUpIngredients(...)`** (parámetros nombrados; con default en `shape` solo es obligatorio tocar el de producción, pero conviene actualizar el resto):
1. `BreadUp/ViewModel/BreadCalculatorVM.swift` (`save()` — producción, real).
2-3. `BreadUp/View/RecipeRow.swift` (`#Preview`, x2).
4. `BreadUp/View/RecipeSavedDetailView.swift` (`#Preview`).
5. `BreadUp/SwiftData/BreadUpMigrationPlan.swift` (fixture `Ingredients.example`).

⚠️ Precedente a tener presente: la migración V2→V3 de este proyecto cambió tipo/nombre de una propiedad (`flourType: FlourType` → `flourTypeString: String`) como `.lightweight`, sin documentarlo en su momento. Para V5 (solo *añadir* un campo con default, como V3→V4) `.lightweight` es correcto y sin ese riesgo.

### 2. `BreadUp/Model/Model.swift` (Generable)

No existe ningún ejemplo (`exampleRecipeBread` o similar) inyectado en el prompt hoy — nada que editar ahí. Si la decisión de diseño (ver abajo) es que el modelo ajuste horneado vía `@Guide`, el conflicto con el prompt actual (ver punto 4) hay que resolverlo antes de tocar este fichero.

### 3. `BreadUp/Model/Tools.swift` (Tooling)

Fuera de alcance — `GetBreadRecipeTool` está desconectado de la sesión activa (`initVM()` lo tiene comentado). No tocar salvo que se decida activar tool-calling, lo cual no es necesario para esta fase.

### 4. `BreadUp/ViewModel/BreadCalculatorVM.swift` — el fichero con más cambios

- Nuevas properties junto a `water`/`flourType`/`flourQuantity`/`yeast`: `var breadShape: BreadShape = .hogaza`, `var pieceWeight: Int = <derivado de doughWeight por defecto>`.
- `calculateHydratation()` ya calcula `temperature`/`time`/`internalTemperature` a partir de `flourType`/`water`/`flourQuantity`/`yeast`; `doughWeight` (= `flourQuantity + water + yeast`) es el peso **total** de la masa, conceptualmente distinto de "peso de una pieza" si se divide la masa.
- **Conflicto real a resolver antes de escribir código**: el prompt en `generateRecipeBread()` ya instruye al modelo "Condiciones de horneado... oriéntate por ellas, **no las contradigas**" sobre `temperature`/`time` ya calculados. Si forma/peso se añaden solo como texto libre sin tocar `calculateHydratation()`, el modelo no puede ajustar coherentemente el horneado por forma sin violar esa instrucción. Ver decisión pendiente 1, abajo.
- `save()` y `resetIngredients()`: pasar `shape`/`shapeString` al constructor de `Ingredients`, resetear `breadShape`/`pieceWeight` a sus defaults tras guardar.

### 5. `BreadUp/View/RecipeDetailView.swift`

Replicar el patrón exacto de la Section "Harina" (Picker con `ForEach(Enum.allCases)` + VStack con Slider/accessibilityLabel-Value/HStack min-max), como nueva Section "Forma de la pieza" tras la Section "Agua" y antes del botón "Generar receta".

### 6. `BreadUpTests/BreadUpTests.swift`

- Los tests oráculo existentes (`bakingParametersForWheatAt70PercentMatchManualOracle`, `ovenAndCoreTemperatureAtMidHydration` parametrizado con `BakingProfileCase`, `bakeTimeClampsToUpperBound`) no fijan hoy forma/peso — si `calculateHydratation()` pasa a depender de ellos, necesitan un default neutro que reproduzca los valores actuales (p. ej. `.hogaza` con peso = `doughWeight` sin variación), o los oráculos hay que recalcularlos.
- `savePersistsIngredientsRecipeAndSteps` / `saveResetsIngredientsToDefaults`: nuevas aserciones sobre `shape`/`breadShape` si se persiste.
- Patrón `BakingProfileCase`/`HydrationBoundaryCase` (structs `Sendable` + `@Test(arguments:)`) es el que replicar para un `BreadShapeCase` nuevo.
- No hay target de UI Tests — coherente con la regla de `CLAUDE.md` (Swift Testing únicamente).

## Decisiones de diseño (resueltas)

1. **¿`calculateHydratation()` incorpora forma/peso al cálculo determinístico, o se añaden solo como texto libre al prompt?**
   - **Elegida: Opción A** — se amplió `calculateHydratation()` (ajuste de `temperature` ±10°C por forma dentro de 190–250°C, `time` en función del peso real de la pieza, molde ×1.1 por retención). Coherente con la instrucción "no contradigas" ya en el prompt; determinista y testeable con oráculos calculados a mano.
2. **¿Se persiste `pieceWeight` en SwiftData (V5), o queda transitorio?**
   - **Elegida: Opción B** — se persiste también `pieceWeight: Int` en `Ingredients` V5, junto a `shape`.

## Fuera de alcance

- No se modela profundidad/diámetro exacto del molde, ni distintos tipos de horno — se asume horno doméstico convencional, coherente con Modernist Cuisine/King Arthur.

## Verificación

Generar una receta para hogaza vs. molde con los mismos ingredientes y comprobar que la temperatura/tiempo de horno sugeridos por el modelo difieren de forma razonable entre ambas formas. Verificado: 38/38 tests en verde en la implementación inicial (oráculos de forma calculados a mano, ver `BreadUpTests.swift`).

## Estado final (2026-08-07)

Implementación completa según el diseño de este documento, más un refinamiento de UX post-implementación:

- **Refinamiento de UX — `pieceWeight` deja de ser editable.** La primera versión incluía un `Slider` para ajustar `pieceWeight` manualmente (con un flag `pieceWeightManuallyAdjusted` en el VM para no resincronizarlo tras el ajuste). El usuario señaló que, al ser un valor 100% derivado de agua+harina+levadura, un `Slider` no encajaba — consultado el HIG de Apple: [Sliders](https://developer.apple.com/design/human-interface-guidelines/sliders) son para valores que el usuario ajusta directamente ("a control... that people can adjust"), mientras que [Labels](https://developer.apple.com/design/human-interface-guidelines/labels) son "texto estático que se lee pero no se edita" — el patrón correcto para un valor calculado. Se sustituyó el `Slider` por `LabeledContent("Peso de la pieza", value: "\(vm.pieceWeight) g")` de solo lectura, con un footer explicando que se calcula automáticamente. Se eliminó `pieceWeightManuallyAdjusted` del VM y toda la lógica de override manual asociada (ya no aplica: `calculateHydratation()` siempre recalcula `pieceWeight = flourQuantity + water + yeast`), y se eliminó el test que verificaba ese comportamiento manual (`manuallyAdjustedPieceWeightIsNotOverwritten`).
- Verificación final: 37/37 tests en verde, build sin warnings.
