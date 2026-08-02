//
//  RecipeListView.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano Fresno on 8/4/26.

import SwiftData
import SwiftUI
import FoundationModels

/// Lista principal de recetas de pan guardadas por el usuario.
///
/// ## Overview
///
/// `RecipeListView` muestra todas las recetas persistidas en SwiftData,
/// ordenadas de más reciente a más antigua. Integra un buscador desplegable
/// en la barra inferior y una hoja de filtros para afinar los resultados
/// por tipo de harina y rango de fechas.
///
/// La vista gestiona tres estados vacíos diferenciados:
///
/// - **Apple Intelligence no disponible** — el modelo on-device no está activo;
///   se muestra un aviso y se oculta el botón de nueva receta.
/// - **Sin recetas** — la base de datos está vacía; se invita al usuario a crear
///   la primera receta pulsando el botón `+`.
/// - **Sin resultados** — hay recetas pero ninguna coincide con la búsqueda
///   o los filtros activos.
///
/// ## Dependencias de entorno
///
/// La vista requiere dos objetos inyectados en el entorno SwiftUI:
///
/// | Entorno | Tipo | Uso |
/// |---|---|---|
/// | `\.modelContext` | `ModelContext` | Borrar recetas de SwiftData |
/// | `BreadCalculatorVM` | `BreadCalculatorVM` | Navegación y disponibilidad del modelo |
///
/// ## Integración
///
/// Integración mínima dentro de un `NavigationStack` con el contenedor de
/// SwiftData ya configurado en la escena:
///
/// ```swift
/// NavigationStack(path: $vm.path) {
///     RecipeListView()
///         .navigationDestination(for: Route.self) { route in
///             switch route {
///             case .detail:
///                 RecipeDetailView()
///             case .saved(let recipe):
///                 RecipeSavedDetailView(recipe: recipe)
///             }
///         }
/// }
/// .environment(vm)
/// .modelContainer(AppModelStore.shared)
/// ```
///
/// ### Preview aislada
///
/// Para previsualizar la vista de forma aislada, proporciona un
/// `BreadCalculatorVM` vacío. SwiftData poblará la lista con los datos
/// del contenedor de preview si los hay:
///
/// ```swift
/// #Preview {
///     RecipeListView()
///         .environment(BreadCalculatorVM())
/// }
/// ```
struct RecipeListView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(BreadCalculatorVM.self) private var vm

  /// Recetas cargadas desde SwiftData, ordenadas de más reciente a más antigua.
  ///
  /// Las recetas sin fecha (`created == nil`) quedan al final porque SwiftData
  /// coloca los `nil` al final en orden `.reverse`. En la práctica todas las
  /// recetas guardadas incluyen fecha.
  @Query(sort: \BreadUpIngredients.created, order: .reverse)
  private var recipes: [BreadUpIngredients]

  /// Texto introducido en el buscador inferior.
  ///
  /// Se compara (sin distinguir mayúsculas ni diacríticos) contra el título
  /// de la receta y el nombre del tipo de harina.
  @State private var searchText = ""

  /// Controla la presentación de la hoja de filtros.
  @State private var showFilters = false

  /// Tipo de harina seleccionado como filtro. `nil` significa "todas las harinas".
  @State private var flourFilter: FlourType?

  /// Activa el filtrado por rango de fechas usando `dateFrom` y `dateTo`.
  @State private var useDateRange = false

  /// Límite inferior del rango de fechas cuando `useDateRange` está activo.
  ///
  /// Se inicializa a un mes antes de la fecha actual.
  @State private var dateFrom: Date =
    Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now

  /// Límite superior del rango de fechas cuando `useDateRange` está activo.
  @State private var dateTo: Date = .now

  /// `true` mientras el buscador inferior está expandido.
  @State private var isSearching = false

  /// Gestiona el foco del `TextField` del buscador inferior.
  @FocusState private var searchFocused: Bool

  var body: some View {
    recipeList
      .overlay {
          if !vm.availableModel() {
              ContentUnavailableView(
                "Apple Intelligence no disponible",
                systemImage: "apple.intelligence",
                description: Text(
                  "Esta app necesita Apple Intelligence activo en el dispositivo. Actívalo en Ajustes › Apple Intelligence y Siri."
                )
              )
          }
          else if recipes.isEmpty {
          ContentUnavailableView(
            "No hay recetas",
            systemImage: "cooktop",
            description: Text("Pulsa + para crear tu primera receta")
          )
        } else if filteredRecipes.isEmpty {
          ContentUnavailableView(
            "Sin resultados",
            systemImage: "line.3.horizontal.decrease.circle",
            description: Text("Prueba a ajustar la búsqueda o los filtros")
          )
        }
      }
      .navigationTitle(vm.availableModel() ? "Mis recetas de pan": "" )
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
          if vm.availableModel() {
              ToolbarItem(placement: .primaryAction) {
                Button {
                  vm.path.append(.detail)
                } label: {
                  Image(systemName: "plus")
                }
                .accessibilityLabel("Nueva receta de pan")
                .accessibilitySortPriority(1)
              }
          }
      }
      .safeAreaBar(edge: .bottom) {
        if !recipes.isEmpty {
          bottomSearchBar
        }
      }
      .sheet(isPresented: $showFilters) {
        filtersSheet
      }
      .onChange(of: isSearching) { _, searching in
        searchFocused = searching
      }
  }

  // MARK: - Lista

  private var recipeList: some View {
    List {
      ForEach(filteredRecipes) { recipe in
        NavigationLink(value: Route.saved(recipe)) {
          RecipeRow(recipe: recipe)
        }
        .swipeActions(edge: .leading) {
          Button {
            toggleFavorite(recipe)
          } label: {
            Label(
              recipe.isFavorite ? "Quitar de favoritos" : "Marcar como favorita",
              systemImage: recipe.isFavorite ? "star.slash" : "star.fill"
            )
          }
          .tint(.yellow)
        }
      }
      .onDelete(perform: deleteRecipes)
    }
  }

  // MARK: - Búsqueda (barra inferior)

  /// Barra inferior adaptativa: muestra los controles de filtro y búsqueda en
  /// reposo, y despliega el campo de texto al activar la búsqueda.
  ///
  /// Solo se renderiza cuando hay al menos una receta guardada. Al abrir el
  /// buscador, el foco del teclado se transfiere automáticamente al
  /// `TextField` vía el `onChange` en `body`.
  @ViewBuilder
  private var bottomSearchBar: some View {
    if isSearching {
      searchFieldBar
    } else {
      HStack {
        filterButton
        Spacer()
        Button {
          withAnimation(.easeInOut) { isSearching = true }
        } label: {
          Image(systemName: "magnifyingglass")
        }
        .buttonStyle(.glass)
        .accessibilityLabel("Buscar")
      }
      .padding(.horizontal)
      .padding(.vertical, 4)
    }
  }

  private var filterButton: some View {
    Button {
      showFilters = true
    } label: {
      Image(
        systemName: hasActiveFilters
          ? "line.3.horizontal.decrease.circle.fill"
          : "line.3.horizontal.decrease.circle")
    }
    .buttonStyle(.glass)
    .accessibilityLabel("Filtros")
    .accessibilityValue(hasActiveFilters ? "Activos" : "Ninguno")
  }

  /// Campo de búsqueda expandido en la barra inferior.
  ///
  /// Incluye un icono de lupa decorativo, el `TextField` con foco automático
  /// y un botón `xmark` que cierra el buscador y limpia el texto introducido.
  /// El icono del botón cambia a `xmark.circle.fill` mientras hay texto.
  private var searchFieldBar: some View {
    HStack(spacing: 10) {
      HStack(spacing: 8) {
        Image(systemName: "magnifyingglass")
          .foregroundStyle(.secondary)
        TextField("Buscar por receta o tipo de harina", text: $searchText)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
          .focused($searchFocused)
          .submitLabel(.search)
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 10)
      .background(.regularMaterial, in: Capsule())
        Button {
                withAnimation(.easeInOut) {
                    isSearching = false
                    searchText = ""
                }
        } label: {
            Image(systemName: !searchText.isEmpty ? "xmark.circle.fill" :
                    "xmark.circle" )
        }
        .buttonStyle(.glass)
        .foregroundStyle(.primary)
        .accessibilityLabel("Cerrar búsqueda")
    }
    .padding(.horizontal)
    .padding(.vertical, 4)
  }

  // MARK: - Filtrado

  /// `true` cuando hay al menos un filtro de atributo activo.
  ///
  /// La búsqueda de texto **no** se considera filtro de atributo: no cambia
  /// el icono del botón de filtros ni habilita el botón de limpiar en la hoja.
  private var hasActiveFilters: Bool {
    flourFilter != nil || useDateRange
  }

  /// Subconjunto de `recipes` tras aplicar la búsqueda por texto y los filtros
  /// de tipo de harina y rango de fechas.
  ///
  /// La coincidencia de texto es insensible a mayúsculas y diacríticos y se
  /// evalúa tanto sobre el título de la receta (`calculateBread.recipe`) como
  /// sobre el nombre del tipo de harina (`flourType.displayName`).
  ///
  /// Los tres predicados se combinan con `&&`:
  /// 1. `matchesText` — texto vacío pasa todo.
  /// 2. `matchesFlour` — `flourFilter == nil` pasa todo.
  /// 3. `matchesDate` — solo activo si `useDateRange == true`.
  private var filteredRecipes: [BreadUpIngredients] {
    recipes.filter { recipe in
      let matchesText =
        searchText.isEmpty
        || (recipe.calculateBread?.recipe ?? "")
          .localizedCaseInsensitiveContains(searchText)
        || recipe.flourType.displayName
          .localizedCaseInsensitiveContains(searchText)
      let matchesFlour = flourFilter == nil || recipe.flourType == flourFilter
      let matchesDate = !useDateRange || dateInRange(recipe.created)
      return matchesText && matchesFlour && matchesDate
    }
  }

  /// Comprueba si una fecha cae dentro del rango `[dateFrom, dateTo]`, ambos
  /// extremos inclusivos a nivel de día completo.
  ///
  /// El rango se calcula como `[startOfDay(dateFrom), startOfDay(dateTo) + 1 día)`,
  /// de modo que todo el día `dateTo` queda incluido.
  ///
  /// - Parameter date: Fecha a comprobar. Devuelve `false` si es `nil`.
  /// - Returns: `true` si `date` se encuentra dentro del rango activo.
  private func dateInRange(_ date: Date?) -> Bool {
    guard let date else { return false }
    let calendar = Calendar.current
    let start = calendar.startOfDay(for: dateFrom)
    let startOfLastDay = calendar.startOfDay(for: dateTo)
    guard let end = calendar.date(byAdding: .day, value: 1, to: startOfLastDay)
    else { return false }
    return date >= start && date < end
  }

  // MARK: - Hoja de filtros

  private var filtersSheet: some View {
    NavigationStack {
      Form {
        Section("Tipo de harina") {
          Picker("Harina", selection: $flourFilter) {
            Text("Todas").tag(FlourType?.none)
            ForEach(FlourType.allCases) { type in
              Text(type.displayName).tag(FlourType?.some(type))
            }
          }
        }
        Section("Fecha de elaboración") {
          Toggle("Filtrar por fecha", isOn: $useDateRange)
          if useDateRange {
            DatePicker(
                "Desde", selection: $dateFrom, in: ...dateTo, displayedComponents: .date)
            DatePicker(
              "Hasta", selection: $dateTo, in: dateFrom...,
              displayedComponents: .date)
          }
        }
      }
      .navigationTitle("Filtros")
      .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .cancel) {
                        showFilters = false
                    }
                    .accessibilityLabel("Cerrar filtros")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: clearFilters) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .disabled(!hasActiveFilters)
                    .accessibilityLabel("Limpiar filtros")
                }
            }
        }
    .presentationDetents([.medium])
  }

  // MARK: - Acciones

  /// Restablece todos los filtros de atributo a su estado inicial.
  ///
  /// Pone `flourFilter` a `nil` y `useDateRange` a `false`. El texto de
  /// búsqueda **no** se limpia aquí; se gestiona de forma independiente
  /// en `searchFieldBar`.
  private func clearFilters() {
    withAnimation {
      flourFilter = nil
      useDateRange = false
    }
  }

  /// Elimina las recetas en los índices indicados de `filteredRecipes`.
  ///
  /// El borrado opera sobre `filteredRecipes` (no sobre `recipes` completo)
  /// para que el índice del gesto swipe-to-delete coincida con la fila
  /// visible. Tras eliminar del `ModelContext`, desindexiza la receta de
  /// Spotlight de forma asíncrona.
  ///
  /// - Parameter offsets: Índices de `filteredRecipes` a eliminar, tal como
  ///   los proporciona el modificador `.onDelete`.
  private func deleteRecipes(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        let recipeOffset = filteredRecipes[index]
        modelContext.delete(recipeOffset)
        Task {
              try await RecipeBreadSpotlightIndexer.delete(recipe: recipeOffset)
        }
      }
    }
  }

  /// Alterna el estado de favorita de `recipe` y persiste el cambio de forma
  /// inmediata (sin depender del autosave del `ModelContext`).
  private func toggleFavorite(_ recipe: BreadUpIngredients) {
    recipe.isFavorite.toggle()
    if modelContext.hasChanges {
      try? modelContext.save()
    }
  }
}

#Preview {
  RecipeListView()
    .environment(BreadCalculatorVM())
}
