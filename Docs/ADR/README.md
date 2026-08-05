# Architecture Decision Records (ADR) — BreadUp

Registro de decisiones de arquitectura relevantes del proyecto: qué se decidió, por qué, y qué alternativas se descartaron. Un ADR se crea cuando una decisión es difícil de revertir o no es obvia solo leyendo el código (p. ej. elección de una estrategia de generación con FoundationModels, diseño de una migración de schema, patrón de navegación). No sustituye a `Docs/Specs/` (qué se va a construir) ni a `Docs/Progress.md` (qué se ha construido) — un ADR documenta *por qué* se construyó así.

## Convención

- Fichero: `NNNN-titulo-corto-en-kebab-case.md`, numeración secuencial de 4 dígitos empezando en `0001`.
- Plantilla: `template.md` en esta misma carpeta.
- Estados: `Propuesto` · `Aceptado` · `Rechazado` · `Reemplazado por NNNN` (si una decisión posterior lo sustituye, se enlaza aquí en vez de borrar el ADR original).
