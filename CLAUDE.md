# CLAUDE.md — BreadUp

> Este fichero nació de fusionar la constitución específica de BreadUp con la constitución de ingeniería genérica Swift/Apple Platforms traída por el plugin `swift-agentic@ac-academy` (antes en `other/CLAUDE.md`, ya no existe — su contenido quedó incorporado aquí). Donde ambos decían lo mismo con distinta redacción, se dejó una sola regla unificada. Las 3 tensiones reales que la fusión no podía resolver por sí sola (duplicación de agentes, duplicación del skill de testing, arquitectura SwiftData `@ModelActor` vs `@MainActor`) ya están decididas — buscar "Decisión tomada" para ver el razonamiento de cada una.

## Qué es BreadUp

App iOS de recetas de pan que usa **FoundationModels** (modelo on-device de Apple Intelligence) para generar recetas a partir de los ingredientes que el usuario configura (tipo de harina, cantidades de harina/agua/levadura, fecha). Las recetas y sus ingredientes se persisten con **SwiftData**.

Es un proyecto exploratorio/de aprendizaje: hay abundante código comentado, ficheros stub (`CloudKit/Cloudkit.swift`, `basura.swift` están vacíos) y módulos a medio implementar (AppEntity/Intents/Spotlight devuelven `[]`). No asumas que todo lo que existe está en uso por el flujo principal.

## Comandos

Build, arranque y tests van **exclusivamente** vía el MCP `xcode`. No hay comandos de shell recomendados para este proyecto.

- Esquema único: `BreadUp`. Bundle id `com.josemanuel.lezcano.BreadUp`.
- **FoundationModels solo funciona en dispositivos con Apple Intelligence habilitado.** En simuladores/dispositivos no elegibles, `SystemLanguageModel.default.availability` será `.unavailable(...)` y la generación de recetas no se ejecuta (la UI lo refleja en `RecipeDetailView`).

### MCP `xcode` (obligatorio, sin excepciones)

El `.xcodeproj` **no se toca nunca internamente a través del shell** (`xcodebuild`, edición manual del `.pbxproj`, o `Read`/`Write`/`Edit`/`Grep` estándar sobre `BreadUp/**/*.swift` u otros ficheros del target). Usa siempre las herramientas del MCP `xcode` (`XcodeRead`/`XcodeWrite`/`XcodeGrep`/`BuildProject`/`RunAllTests`/`RunSomeTests`/`RenderPreview`/`XcodeRM`…). Si por cualquier motivo excepcional fuera necesario recurrir al shell, **pide autorización expresa y justifica el motivo antes de hacerlo** — nunca por iniciativa propia, ni siquiera como fallback si el MCP está desconectado (en ese caso, informa y espera a que se reconecte). Ficheros fuera del proyecto (este `CLAUDE.md`, `.claude/`, `Docs/`, scripts) van por las herramientas estándar.

Preferir siempre el MCP de Xcode para builds, tests y mutaciones del proyecto; si el tooling no puede hacer algo (targets, capabilities), parar y preguntar — sin workarounds, y nunca resolver un problema añadiendo una dependencia.

## Testing

- **Tests unitarios: solo Swift Testing** (`import Testing`, `@Test`, `#expect`) — target `BreadUpTests`. No uses XCTest para tests unitarios.
- **XCTest se reserva exclusivamente para UI Tests** — es la única herramienta disponible para ese propósito a mayo de 2026 (Swift Testing no cubre todavía UI testing).
- Ejecuta siempre los tests vía el MCP `xcode` (`RunAllTests`/`RunSomeTests`/`GetTestList`), nunca `xcodebuild test` en shell.
- Un test verifica comportamiento observable de código de producción contra un oráculo independiente de ese código (fixtures, requisitos externos) — nunca lo que el compilador ya garantiza (casos de enum, forma de un DTO, conformidades). Si un test pasaría siempre que el código compile, bórralo.
- Mock en las costuras diseñadas en producción: `URLProtocol` para red, protocolos de repositorio inyectados para datos. Ejecuta el pipeline real (fetch → decode → map → persist) con el transporte mockeado — nunca contra backends reales.
- Nunca modifiques un test para que pase — arregla la implementación. Sin regresiones: un cambio no es válido si rompe tests que ya estaban en verde.

**Decisión tomada 2026-08-25**: esta doctrina de testing vivía, con mucho más detalle y ejemplos de código, en el skill propio `tests-que-prueban-de-verdad`. Se confirmó que el skill `swift-agentic:tests-de-verdad` del plugin era un superconjunto estricto (contenía ese mismo texto palabra por palabra como referencia interna, más una guía de migración XCTest→Swift Testing que el propio no tenía), así que el skill propio se **eliminó globalmente** (`~/.claude/skills/tests-que-prueban-de-verdad/`, ya no existe en ningún proyecto). La doctrina de testing de este `CLAUDE.md` remite ahora en exclusiva a `swift-agentic:tests-de-verdad`.

## Configuración de compilación crítica

El target impone reglas estrictas que hay que respetar en todo código nuevo:

- **Swift 6**, `SWIFT_STRICT_CONCURRENCY = complete`.
- **`SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated`** → el aislamiento por defecto NO es `@MainActor`. Anota `@MainActor` explícitamente donde toque UI/`ModelContext` en el hilo principal.
- **`SWIFT_TREAT_WARNINGS_AS_ERRORS = YES`** → cualquier warning rompe el build. No dejes imports/variables sin usar. Cero warnings no es solo config de build: una tarea no está terminada, un commit no se hace, y una fase no se cierra mientras el build emita un solo warning.
- Deployment target iOS 26. `SUPPORTED_PLATFORMS = iphoneos iphonesimulator macosx`.
- **Icono de la app: formato `.icon` (Icon Composer, norma de Xcode 26)**. Ya está configurado — no uses el formato clásico `.appiconset`/PNGs sueltos dentro de `Assets.xcassets` para el icono.

## Directrices primordiales

- No especules. Si no sabes algo, verifícalo o dilo — nunca presentes una suposición como un hecho.
- No decidas por tu cuenta. Cualquier cosa que el usuario no haya zanjado ya, consúltala primero.
- Piensa antes de actuar. Produce un plan antes de escribir código o texto, y que se valide.
- Modifica solo lo estrictamente necesario — el cambio mínimo que cumple la tarea, nada más.
- Limpia tu propio desorden: elimina ficheros temporales, andamiaje, salidas de depuración y código muerto que hayas creado antes de dar por terminado.
- No hagas nada que no se haya pedido explícitamente. Si una acción no pedida parece necesaria, pregunta antes de hacerla.
- Itera en bucle contra un verificador (subagentes de tarea, tests, build) hasta cumplir el criterio de éxito. Tu propio juicio sobre el trabajo no es la condición de salida — lo es el verde del verificador.

## Reglas innegociables

- **Prohibidos los opcionales forzados**: nunca `!`, `as!`, `try!`, ni implícitamente desempaquetados. Usa `guard let`/`if let`/`??`/`?.`. Única excepción: cargar fixtures de test puede fallar de forma ruidosa en código de test.
- **Verifica antes de asumir**: antes de proponer código, framework o API, comprueba documentación real — MCP `xcode` primero, si no basta MCP `cupertino`, y si aún falta información `WebFetch`/`WebSearch`. No des por buena una solución solo por conocimiento interno del modelo — los LLM tienden a sesgarse hacia APIs obsoletas.
- **No toques código que ya funciona sin proponerlo antes**: cualquier cambio sobre código funcional existente (no trivial, un refactor, una "mejora") requiere presentar la propuesta y esperar confirmación explícita antes de aplicarla.
- **No declares `Sendable` redundante**: `struct`, `enum` y `actor` son Sendable por sí mismos cuando corresponde (el compilador lo infiere/garantiza) — no añadas la conformidad explícita.
- **Sin atajos de concurrencia estricta**: prohibido `@preconcurrency`, `@unchecked Sendable`, `nonisolated(unsafe)` o trucos equivalentes para silenciar errores reales de concurrencia. Arréglalo con aislamiento real (`actor`, `@MainActor`, `Sendable` legítimo). Si tras evaluar alternativas de buenas prácticas no hay otra solución, proponla y espera aprobación explícita antes de usarla. *(Excepción documentada en el ecosistema general, no aplica a BreadUp: los modelos Fluent en Vapor requieren `@unchecked Sendable` — BreadUp no tiene backend Vapor.)*
- **Nunca hardcodees secretos ni los commitees**: datos sensibles (tokens, contraseñas) van en Keychain, nunca en UserDefaults, código fuente o logs.
- **Sin dependencias de terceros**: solo frameworks de Apple y código propio, salvo aprobación explícita.
- **Nada de APIs obsoletas u Objective-C**, salvo aprobación previa:

  | Prohibido | Alternativa moderna |
  |---|---|
  | `@objc`, `#selector` | closures y acciones SwiftUI |
  | `NotificationCenter.addObserver(_:selector:)` | `.onReceive`/notificaciones async |
  | Grand Central Dispatch (`DispatchQueue`, `DispatchGroup`, `DispatchSemaphore`) | `async`/`await` |
  | `DateFormatter`, `NumberFormatter`, `String(format:)` | `.formatted()` / `Date.FormatStyle` / `Duration` |
  | `NSRegularExpression` | `Regex` / regex literals nativos de Swift |
  | `UIView.animate`, `CAAnimation` | `withAnimation` |
  | `UIAlertController` | `.alert()` |
  | Ciclo de vida UIKit (`viewDidLoad`...) | `.task`/`.onAppear` |
  | `JSONSerialization` | `Codable` |
  | `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject` | `@Observable` (patrón ya usado por `BreadCalculatorVM`) |

  Excepciones permitidas solo donde la API de Apple las exige (p. ej. la queue de `NWPathMonitor`, protocolos delegate del sistema que requieren `@objc`) — documenta cada una con un comentario.
- **Todo ViewModel `@Observable` debe ser `@MainActor` explícito**: `@Observable` por sí solo no aísla al actor principal — anota la clase con `@MainActor` explícitamente (ya el patrón de `BreadCalculatorVM`).
- **Todo código concurrente usa `async`/`await`** — nunca Combine ni GCD.

## Concurrencia (Swift 6, estricta)

- `SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated` en este proyecto — el aislamiento por defecto NO es `@MainActor`; anótalo explícitamente donde toque UI/`ModelContext` en el hilo principal.
- Adopta Approachable Concurrency (SE-0461/SE-0466) cuando aplique.
- Usa `actor` para estado mutable compartido. Los tipos que cruzan fronteras de aislamiento deben ser `Sendable` (structs/enums/actors ya lo son — sin conformidades redundantes).
- Paralelismo: `async let` para un conjunto fijo, `TaskGroup` para colecciones dinámicas. Nunca `await` serial dentro de un bucle que podría paralelizarse. Comprueba `Task.checkCancellation()` en bucles largos.
- Nunca puentees actores con `withCheckedContinuation` envolviendo un `Task { @MainActor in }` — extrae una función `@MainActor async` y haz `await` sobre ella.
- `async`/`await` únicamente. Prohibido GCD y completion handlers; Combine solo con justificación explícita.

## SwiftUI

- Controles nativos únicamente. Nunca construyas un componente personalizado que reemplace uno nativo (`.searchable`, `Picker`, `Form`+`Section`+`LabeledContent`, `TabView`+`Tab`+`TabSection`, `.toolbar`). Un look personalizado sobre un control nativo = un `*Style`; nunca un struct paralelo.
- Cero lógica de negocio en las Views. Validación, transformación, persistencia y orquestación viven en el ViewModel de la pantalla; helpers de presentación en `extension <Model>`. La View pasa `modelContext` a los métodos del ViewModel; el ViewModel nunca lee el Environment de SwiftUI directamente. *(Ya es el patrón documentado de BreadUp — ver Arquitectura más abajo.)*
- Un tipo por fichero, nombrado igual que el tipo. Nada de `private struct AlgunaView: View` dentro de otro fichero. Mantén el `body` plano — no lo fragmentes en propiedades `private var x: some View`; extrae ficheros `View` reales. Extrae cualquier átomo de UI usado en más de un sitio.
- Navegación: `NavigationStack` + `NavigationLink(value:)` + `navigationDestination`. Nunca `NavigationView`, nunca un Router/Sidebar a medida.
- Tipografía: solo estilos de texto semánticos (`.body`, `.headline`, `.title2.bold()`…). Si escribes `.system(size:)` está mal. Los colores viven en el Asset Catalog con variantes light/dark (y alto contraste) — nunca literales hex/RGB en código.
- Cada vista lleva un `#Preview` mínimo alimentado desde datos de muestra centralizados — nunca datos de preview hardcodeados inline, nunca andamiaje envolvente alrededor del componente.
- No hagas `Binding(get:set:)` a mano.

## SwiftData

- SwiftData es la fuente de verdad local; las clases `@Model` son el modelo de dominio.
- Los `ModelContainer` se configuran en el punto de entrada de la app; contenedor en memoria para previews y tests; se comparte vía App Group cuando widgets/extensiones necesitan el store.
- Las migraciones son versionadas y nunca destructivas sin aprobación explícita.
- **Uso real en BreadUp** (ver Arquitectura más abajo): `AppModelStore.shared` es un `ModelContainer` `@MainActor` único, construido con `BreadUpMigrationPlan`, inyectado en la escena. Esquema versionado V1→V5 (`VersionedSchema` + `MigrationStage`), con typealias `BreadUpIngredients`/`BreadUpCalculate`/`BreadUpStepRecipe` repuntados a la versión vigente. Al introducir cambios de modelo, crea una nueva `VersionedSchema` + stage de migración y reapunta los typealias; no edites un schema versionado ya migrado.

**Decisión tomada 2026-08-25**: la constitución genérica prescribe "un único punto de escritura a través de un `@ModelActor` fuera del main actor; las Views leen con `@Query` y mutan solo vía métodos de ViewModel/actor". BreadUp usa deliberadamente el `ModelContainer` `@MainActor` único actual, **sin migrar a `@ModelActor`**: hoy no hay Widget ni watch app compartiendo el store vía App Group, ni escritura pesada en background (la generación de recetas no persiste nada hasta que el usuario pulsa "Guardar", una operación puntual) — los dos escenarios que justifican esa capa. Añadirla ahora sería trabajo sobre código que ya funciona (37/37 tests en verde) sin necesidad real. **Revisar esta decisión si en el futuro se añade** un target Widget/watch que necesite el store compartido, o una importación/sincronización pesada en background.

## APIs modernas

Usa siempre la API más moderna disponible; las obsoletas están prohibidas (ver tabla en "Reglas innegociables"). Declara el target explícitamente al pedir código: Swift 6, iOS 26, Liquid Glass, Approachable Concurrency.

## Accesibilidad

- Todo elemento interactivo tiene `accessibilityLabel` (y un hint cuando la acción no es obvia). Las imágenes decorativas llevan `.accessibilityHidden(true)`; las informativas, un label descriptivo. Agrupa elementos relacionados con `.accessibilityElement(children: .combine)`.
- Dynamic Type en todas partes: estilos de texto semánticos, `@ScaledMetric` para tamaños fijos de chrome, y layouts verificados en AX5 antes de dar una pantalla por cerrada.
- Contraste ≥ 4.5:1 para texto (3:1 para texto grande y formas de UI significativas). Hit targets ≥ 44pt.
- Anuncios: `AccessibilityNotification.Announcement(...).post()` — nunca `UIAccessibility.post`.
- Respeta `accessibilityReduceMotion` y `accessibilityReduceTransparency`.
- Audita cada pantalla terminada contra el criterio WCAG 2.2 AA (subagente `swift-agentic:auditor-accesibilidad` — ver Enrutamiento).

## Seguridad

- Solo HTTPS. Nunca loguear datos sensibles; los mensajes de error no deben filtrar detalles internos.
- Tokens de autenticación: Keychain, validar expiración de JWT localmente, refrescar de forma proactiva (no como reacción a un 401).
- Tratar credenciales ofuscadas también como secretos: nunca reproducirlas en respuestas, commits o docs.
- Ejecutar la checklist de seguridad antes de cualquier PR que toque auth, pagos o datos de usuario.

*(BreadUp hoy no tiene backend, autenticación ni pagos — esta sección queda documentada para cuando el proyecto crezca en esa dirección, no describe una superficie de ataque actual.)*

## Flujo de trabajo

- Convierte peticiones vagas en criterios de aceptación verificables antes de escribir una sola línea; declara tus suposiciones explícitamente.
- Plan Mode para cualquier cosa que toque 3+ ficheros, schemas, auth, pagos, concurrencia o navegación. Persiste los planes en disco — son la memoria externa del agente.
- Cada línea cambiada debe trazarse hasta la petición; sin abstracciones no solicitadas.
- Busca patrones ya existentes en el código antes de escribir código nuevo; el código real gana sobre la documentación desactualizada cuando entran en conflicto.
- Definición de terminado: build con cero warnings + tests en verde + (para UI) verificación visual. Decide una señal externa en verde — no la propia opinión del agente sobre su trabajo.
- Si una API no se comporta como el plan asumía, para y repórtalo antes de inventar un workaround.
- Cierra el bucle: commitea en checkpoints, registra el progreso, limpia contexto entre unidades de trabajo.

## Arquitectura

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

## Enrutamiento — qué skill leer antes de trabajar en cada área

| El problema toca… | Skill a leer |
|---|---|
| Cualquier vista, pantalla, formulario, lista, navegación, toolbar, preview SwiftUI | `swift-agentic:swiftui-moderno` |
| async/await, Task, actor, Sendable, aislamiento, warnings de concurrencia | `swift-agentic:concurrencia-swift` |
| Labels, VoiceOver, Dynamic Type, contraste, cierre de pantalla | `swift-agentic:accesibilidad-ios` |
| Una API legacy/obsoleta, o migrar patrones antiguos | `swift-agentic:apis-modernas` |
| Escribir o auditar cualquier test, migrar XCTest | `swift-agentic:tests-de-verdad` |
| `@Model`, `ModelContainer`, `@Query`, migraciones, widgets compartiendo datos | `swift-agentic:swiftdata` |
| Auth, tokens, secretos, pagos, logging, HTTPS | `swift-agentic:seguridad-apple` |
| LLM on-device (Apple Intelligence, `@Generable`) | `swift-agentic:foundation-models` |

Checkpoints de subagente — **decisión tomada 2026-08-25**: para BreadUp se usan en exclusiva los 6 agentes de `swift-agentic`. `swift-architect`, `swift-testing-engineer` y `accessibility-auditor` (el sistema propio previo, con el que estos 3 solapaban en función) **no se invocan en este proyecto** — siguen definidos globalmente (`~/.claude/agents/`) para uso en otros proyectos, no se han borrado. `swiftdata-specialist` y `swiftui-designer` no solapaban con ningún agente de `swift-agentic` (no hay equivalente) y siguen en uso normal donde ya se usaban.

- Tras cualquier unidad de trabajo, antes de cerrar → `swift-agentic:revisor-constitucion` (auditoría de cumplimiento, solo lectura).
- Tras escribir código concurrente → `swift-agentic:auditor-concurrencia`.
- Al terminar una pantalla → `swift-agentic:auditor-accesibilidad` (auditoría + fixes de presentación).
- Antes de implementar una feature → `swift-agentic:ingeniero-tests` (TDD: tests en rojo primero).
- Tras cualquier cambio que afecte a la UI → `swift-agentic:verificador-ui` (build, run, interactuar, verificar). Iterar hasta que devuelva ✅ — es el verificador del bucle.
- Antes de un PR que toque auth/pagos/datos de usuario → `swift-agentic:auditor-seguridad`.
