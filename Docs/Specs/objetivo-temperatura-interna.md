# Objetivo de temperatura interna de cocción

**Prioridad:** Leve

## Contexto

Hoy `BreadRecipe`/`StepRecipe` (`Generable.swift`) generan pasos que incluyen un tiempo de horno, pero ninguna referencia a temperatura interna. Según las fuentes recogidas (`Docs/Specs/SOURCES-INFO.md` — King Arthur, ThermoWorks, wordloaf), el tiempo de horno es solo orientativo: depende de la forma y el tamaño de la pieza, algo que la app no pregunta hoy. El único indicador fiable de que el pan está hecho es la temperatura interna: masas magras (baguette, hogaza, masa madre) ~96–99 °C (205–210 °F). BreadUp genera exclusivamente este tipo de masa. Sin esta nota, el usuario puede confiar ciegamente en el tiempo generado y sacar un pan crudo o sobre-horneado.

## Propuesta

- En `Generable.swift`, añadir `@Guide` al último `StepRecipe` (el de horneado) para que el modelo incluya siempre el rango de temperatura interna objetivo (96–99 °C) junto con el tiempo, y una frase que deje claro que el tiempo es orientativo y la temperatura interna es la verificación real. Actualizar `exampleRecipeBread` para reflejar este formato en el ejemplo inyectado al prompt.
- No requiere nuevo campo estructurado ni cambios de schema SwiftData: el dato viaja como parte del texto/instrucciones ya generadas y persistidas en `StepRecipe`.
- En la UI (`StepView`/`StepCard`/`StepsBreadView`), ninguna vista nueva — el paso de horneado ya renderiza el texto generado, que ahora incluirá la nota.

## Alcance

- `BreadUp/FMFBusiness/Generable.swift`: `@Guide` del paso de horneado + `exampleRecipeBread` actualizado.

## Fuera de alcance

- No se añade soporte de termómetro Bluetooth/HealthKit.
- No se diferencian masas enriquecidas (huevo/mantequilla/azúcar/leche) — fuera del dominio actual de la app, que solo genera masa magra.

## Verificación

Generar una receta y comprobar que el último paso incluye el rango 96–99 °C junto con la nota de que el tiempo es orientativo y la temperatura interna es la verificación fiable.
