# Forma y peso de la pieza como input de generación

**Prioridad:** Normal

## Contexto

Según todas las fuentes recogidas (`Docs/SOURCES-INFO.md`), el factor que realmente determina la temperatura y el tiempo de horno es la forma y el tamaño/peso de la pieza (masa magra en hogaza/baguette/molde a 230–250 °C; el tiempo depende del peso) — no la cantidad de harina/agua/levadura que hoy configura el usuario. `RecipeDetailView` nunca pregunta esto, por lo que el modelo genera instrucciones de horno "a ciegas" respecto al factor más determinante según la ciencia panadera.

## Propuesta

- Nuevo enum `BreadShape` (hogaza, baguette, molde), análogo a `FlourType`, con `displayName` en español, definido junto a `FlourType` en `BreadUpMigrationPlan.swift`.
- Nueva `Section` "Forma de la pieza" en `RecipeDetailView`: `Picker` de `BreadShape` + peso aproximado de la pieza final (derivable de harina+agua+levadura, o ajustable manualmente vía slider).
- `BreadCalculatorVM` incorpora `breadShape`/`pieceWeight` en las instrucciones/prompt de generación (`GetBreadRecipeTool`/`BreadArguments`).
- `Generable.swift` usa `@Guide` para que el modelo ajuste temperatura/tiempo de horno generados según la forma (230–250 °C para masa magra) y el peso de la pieza.
- Se persiste `shape: BreadShape` en `BreadUpIngredients` vía nueva `BreadUpSchemaV5` (o V6 si coincide en el tiempo con el diario de horneado), con migración `.lightweight` análoga a como V4 añadió `isFavorite`.

## Alcance

- `BreadUp/SwiftData/BreadUpMigrationPlan.swift`: nuevo enum `BreadShape` + nueva versión de schema con el campo `shape`.
- `BreadUp/View/RecipeDetailView.swift`: nuevo `Picker`/control de peso.
- `BreadUp/FMFBusiness/Tooling.swift` (`BreadArguments`) y `BreadUp/FMFBusiness/Generable.swift`: nuevos parámetros e instrucciones `@Guide`.
- `BreadUp/ViewModel/BreadCalculatorVM.swift`: nuevo estado de formulario.

## Fuera de alcance

- No se modela profundidad/diámetro exacto del molde, ni distintos tipos de horno — se asume horno doméstico convencional, coherente con Modernist Cuisine/King Arthur.

## Verificación

Generar una receta para hogaza vs. molde con los mismos ingredientes y comprobar que la temperatura/tiempo de horno sugeridos por el modelo difieren de forma razonable entre ambas formas.
