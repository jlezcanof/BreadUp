# Calculadora de DDT integrada en el formulario

**Prioridad:** Normal

## Contexto

La fórmula de Temperatura de Masa Deseada (DDT) —`Agua = (DDT × 3) − Tª ambiente − Tª harina − fricción`— es, según las fuentes recogidas (`Docs/Specs/SOURCES-INFO.md` — King Arthur pro reference), la única fórmula real de la panadería profesional que combina agua + harina + ambiente. Determina la **temperatura del agua** a usar, no la cantidad. Hoy `RecipeDetailView` solo permite ajustar la cantidad de agua (ml) vía slider, sin ninguna referencia a su temperatura, dejando fuera el único cálculo con base científica real que la app podría ofrecer sin necesidad de FoundationModels.

## Propuesta

- Nueva `Section` "Temperatura del agua" en `RecipeDetailView`, tras la sección "Agua", con controles para: temperatura ambiente (slider/stepper, rango razonable ~15–30 °C), temperatura de la harina (opcional, por defecto igual a la ambiente) y factor de fricción (valor por defecto fijo, ej. 2 °C, editable como ajuste avanzado).
- Nuevo método puro en `BreadCalculatorVM`: `calculateDesiredWaterTemp(ambientTemp:flourTemp:friction:) -> Int`, sin dependencia de FoundationModels ni SwiftData — cálculo determinista con la fórmula DDT.
- El resultado se muestra como texto informativo bajo el slider de agua ("Usa agua a ~X °C"), actualizado reactivamente al mover cualquiera de los sliders implicados.
- Opcionalmente, el valor sugerido se incluye en las instrucciones/prompt de generación para que el primer paso generado lo mencione explícitamente.

## Alcance

- `BreadUp/View/RecipeDetailView.swift`: nueva sección de UI.
- `BreadUp/ViewModel/BreadCalculatorVM.swift`: nuevo cálculo puro + estado publicado para el resultado.

## Fuera de alcance

- No se persiste la temperatura ambiente/harina en el schema SwiftData (no aporta valor histórico por sí sola; se reconsideraría si el diario de horneado lo necesitara en el futuro).
- No se integra con sensores de temperatura externos ni Bluetooth.

## Verificación

Introducir valores conocidos de agua/harina/ambiente y comprobar que la temperatura de agua sugerida coincide con el cálculo manual de la fórmula DDT; comprobar que se actualiza reactivamente al mover los sliders.
