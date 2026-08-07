# Progress — Specs de BreadUp

Estado de implementación de las specs recogidas en `Docs/Specs/`. Actualizar esta tabla al completar (o descartar) cada una.

**Leyenda:** Pendiente · En progreso · Implementado · Descartado

| Spec | Prioridad | Estado |
|---|---|---|
| [F01_Phase_objetivo-temperatura-interna](Specs/F01_Phase_objetivo-temperatura-interna.md) | Leve | Pendiente |
| [F02_Phase_calculadora-ddt](Specs/F02_Phase_calculadora-ddt.md) | Normal | Pendiente |
| [F03_Phase_diario-horneado](Specs/F03_Phase_diario-horneado.md) | Normal | Pendiente |
| [F04_Phase_forma-peso-pieza](Specs/F04_Phase_forma-peso-pieza.md) | Normal | Implementado |

## F04 — resumen de lo implementado (cerrada 2026-08-07)

- **Schema**: `BreadUpSchemaV5.swift` (nuevo) — enum `BreadShape` (hogaza/baguette/molde, mismo patrón que `FlourType`), `Ingredients` con `shapeString`/`pieceWeight` + computed `shape: BreadShape`. Migración `.lightweight` V4→V5 en `BreadUpMigrationPlan.swift`, typealiases repuntados.
- **VM** (`BreadCalculatorVM.swift`): `calculateHydratation()` ajusta `temperature` ±10°C por forma (hogaza = banda neutra, preserva el comportamiento previo) y `time` según el peso real de una pieza (no el lote). `pieceWeight` se recalcula siempre a partir de agua+harina+levadura — no es editable por el usuario (ver refinamiento UX abajo). `save()` persiste `shape`/`pieceWeight`; el prompt de generación incluye forma y peso.
- **UI**: nueva Section "Forma de la masa" en `RecipeDetailView.swift` (Picker de forma + `LabeledContent` de solo lectura para el peso, con footer explicativo); nuevo `IngredientStatTile` "Forma" en la cabecera de `GenerateBreadRecipeView.swift`.
- **Refinamiento UX post-implementación**: el peso de pieza empezó como `Slider` ajustable manualmente; consultado el HIG (Sliders = valores que el usuario ajusta, Labels = texto de solo lectura), se sustituyó por `LabeledContent` ya que es un valor 100% derivado. Se eliminó `pieceWeightManuallyAdjusted` del VM. Detalle completo en la spec, sección "Estado final".
- **Tests**: en `BreadUpTests.swift`, ajuste de temperatura/tiempo por forma con oráculos calculados a mano + auto-derivación de `pieceWeight` + `save`/`reset` con `shape`/`pieceWeight`. 37/37 tests en verde, build sin warnings.
