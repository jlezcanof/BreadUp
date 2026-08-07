# Progress — Specs de BreadUp

Estado de implementación de las specs recogidas en `Docs/Specs/`. Actualizar esta tabla al completar (o descartar) cada una.

**Leyenda:** Pendiente · En progreso · Implementado · Descartado

| Spec | Prioridad | Estado |
|---|---|---|
| [F01_Phase_objetivo-temperatura-interna](Specs/F01_Phase_objetivo-temperatura-interna.md) | Leve | Pendiente |
| [F02_Phase_calculadora-ddt](Specs/F02_Phase_calculadora-ddt.md) | Normal | Pendiente |
| [F03_Phase_diario-horneado](Specs/F03_Phase_diario-horneado.md) | Normal | Pendiente |
| [F04_Phase_forma-peso-pieza](Specs/F04_Phase_forma-peso-pieza.md) | Normal | Implementado |

## F04 — resumen de lo implementado (2026-08-07)

- **Schema**: `BreadUpSchemaV5.swift` (nuevo) — enum `BreadShape` (hogaza/baguette/molde, mismo patrón que `FlourType`), `Ingredients` con `shapeString`/`pieceWeight` + computed `shape: BreadShape`. Migración `.lightweight` V4→V5 en `BreadUpMigrationPlan.swift`, typealiases repuntados.
- **VM** (`BreadCalculatorVM.swift`): `calculateHydratation()` ajusta `temperature` ±10°C por forma (hogaza = banda neutra, preserva el comportamiento previo) y `time` según el peso real de una pieza (no el lote); `pieceWeight` se auto-deriva del peso total hasta que el usuario lo ajusta manualmente en el slider, momento en que deja de resincronizarse. `save()` persiste `shape`/`pieceWeight`; el prompt de generación incluye forma y peso.
- **UI**: nueva Section "Forma de la pieza" en `RecipeDetailView.swift` (Picker + Slider, mismo patrón que las demás secciones); nuevo `IngredientStatTile` "Forma" en la cabecera de `GenerateBreadRecipeView.swift`.
- **Tests**: 5 nuevos en `BreadUpTests.swift` (ajuste de temperatura/tiempo por forma con oráculos calculados a mano, auto-derivación de `pieceWeight`, persistencia del override manual) + 2 ampliados (`save`/`reset` con `shape`/`pieceWeight`). 38/38 tests en verde, build sin warnings.
- **Pendiente**: quedan ajustes menores, se gestionarán como bugs aparte (no bloquean el cierre de esta fase).
