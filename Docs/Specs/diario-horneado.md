# Diario de horneado por receta

**Prioridad:** Normal

## Contexto

Hoy una receta guardada (`BreadUpIngredients` → `CalculateBread` → `StepRecipe`) es de solo lectura una vez generada: no existe forma de registrar cómo salió el pan al hornearlo. Las fuentes recogidas (`Docs/Specs/SOURCES-INFO.md`) insisten en que la única forma fiable de mejorar es verificar el resultado real (temperatura interna, aspecto de miga/corteza). Sin ese circuito de feedback, BreadUp se queda en generador de instrucciones desechables en vez de cumplir su propósito de "cuaderno de recetas" que aprende de la experiencia del usuario.

## Propuesta

- Nueva entidad SwiftData `BakingLog` (nueva `BreadUpSchemaV5`, siguiendo el patrón de `BreadUpSchemaV4`): `date: Date`, `crumbNotes: String?`, `crustNotes: String?`, `rating: Int?` (1–5). Relación 1-N `.cascade` desde `CalculateBread` (una receta puede hornearse varias veces).
- Nuevo `MigrationStage.lightweight` V4→V5 en `BreadUpMigrationPlan.swift`, y nuevo typealias `BreadUpBakingLog`.
- Nueva vista `BakingLogEntryView`, accesible desde `RecipeSavedDetailView` mediante un botón "Registrar horneado", con formulario simple (rating + notas de miga/corteza).
- `RecipeSavedDetailView` añade una sección de historial listando las entradas de esa receta (fecha, valoración, notas), ordenadas por fecha, permitiendo comparar qué combinaciones de ingredientes dieron mejor resultado con el tiempo.

## Alcance

- `BreadUp/SwiftData/BreadUpSchemaV5.swift` (nuevo) + actualización de `BreadUpMigrationPlan.swift`.
- `BreadUp/View/BakingLogEntryView.swift` (nuevo).
- `BreadUp/View/RecipeSavedDetailView.swift`: botón de registro + sección de historial.

## Fuera de alcance

- No se implementa comparación automática/analítica entre entradas (p. ej. "tu mejor hidratación fue...") — solo registro y listado en esta iteración.
- Fotos (`photo: Data?`) se dejan fuera; posible fast-follow si no complica el schema inicial.

## Verificación

Crear una receta, registrar 2–3 entradas de horneado con distinta valoración y notas; comprobar que persisten tras relanzar la app y que se listan ordenadas por fecha en el detalle de la receta guardada.
