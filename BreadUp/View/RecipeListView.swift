//
//  RecipeListView.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano Fresno on 8/4/26.
//

import SwiftData
import SwiftUI

struct RecipeListView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(BreadCalculatorVM.self) private var vm
  // Más recientes primero. `created` es opcional: SwiftData coloca los nil al
  // final con orden inverso (las recetas guardadas siempre llevan fecha).
  @Query(sort: \BreadUpIngredients.created, order: .reverse)
  private var recipes: [BreadUpIngredients]

  // Búsqueda por texto (título de la receta).
  @State private var searchText = ""

  // Filtros por atributo.
  @State private var showFilters = false
  @State private var flourFilter: FlourType?
  @State private var useDateRange = false
  @State private var dateFrom: Date =
    Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
  @State private var dateTo: Date = .now

  // Buscador custom desplegable desde la barra inferior.
  @State private var isSearching = false
  @FocusState private var searchFocused: Bool

  var body: some View {
    recipeList
      .overlay {
        if recipes.isEmpty {
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
      .navigationTitle("Mis Recetas de pan")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            vm.path.append(.detail)
          } label: {
            Image(systemName: "plus")
          }
          .accessibilityLabel("Nueva receta")
        }
      }
      // Barra inferior: en reposo, filtro + lupa; al buscar, el campo de texto
      // desplegado abajo. Solo cuando hay recetas que filtrar/buscar.
      .safeAreaBar(edge: .bottom) {
        if !recipes.isEmpty {
          bottomSearchBar
        }
      }
      .sheet(isPresented: $showFilters) {
        filtersSheet
      }
      // Da/quita el foco al campo al abrir/cerrar el buscador.
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
      }
      .onDelete(perform: deleteRecipes)
    }
  }

  // MARK: - Búsqueda (barra inferior)

  /// En reposo, muestra el filtro (izquierda) y la lupa (derecha). Al activar
  /// la búsqueda, despliega el campo de texto en esa misma zona inferior.
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

  /// Campo de búsqueda desplegado en la barra inferior, con lupa, limpiar y
  /// botón para cancelar (cierra y vacía la búsqueda).
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

  /// Hay filtros de atributo activos (la búsqueda de texto no cuenta como tal).
  private var hasActiveFilters: Bool {
    flourFilter != nil || useDateRange
  }

  /// Recetas tras aplicar búsqueda de título + filtros de harina y fecha.
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

  /// `true` si `date` cae dentro del rango [inicio de `dateFrom`, fin de `dateTo`].
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
        // "Limpiar" vive en la barra del sheet (no en el Form), así no queda
        // pegado a la home indicator y está siempre accesible sin hacer scroll.
        ToolbarItem(placement: .topBarLeading) {
          Button("Limpiar", action: clearFilters)
            .disabled(!hasActiveFilters)
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Listo") { showFilters = false }
        }
      }
    }
    .presentationDetents([.medium])
  }

  // MARK: - Acciones
  private func clearFilters() {
    withAnimation {
      flourFilter = nil
      useDateRange = false
    }
  }

  private func deleteRecipes(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(filteredRecipes[index])
      }
    }
  }
}

#Preview {
  RecipeListView()
    .environment(BreadCalculatorVM())
}
