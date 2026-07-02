//
//  AppIntents.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano Fresno on 01/07/2026.
//


import AppIntents
import SwiftUI
import SwiftData

struct GetRecipeBreadIntent: AppIntent {
    
    static let title: LocalizedStringResource = "Consulta receta de pan en BreadUp"
    
    static let description = IntentDescription("Busca una receta de pan por el nombre", categoryName: "Recetas")
    
    @Parameter(title: "Nombre de la receta" ,requestValueDialog: "Nombre de la receta") var name: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Busca receta de pan por el nombre \(\.$name)")
    }
    
    @MainActor// & ShowsSnippetView
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        //        let providerDialog = ProvidesDialog.result(dialog: intentDialog)
        let intentDialog = IntentDialog("Buscando en BreadUp")

        let store = AppModelStore.shared
        
        // .recipe.contains(name)
        // bread.calculateBread?.recipe == name
        var descriptor = FetchDescriptor<BreadUpIngredients>(
            predicate: #Predicate { bread in
                bread.calculateBread?.recipe == name
//                guard let title = bread.calculateBread?.recipe else {
//                    return false
//                }
//                return title.range(
//                    of: name,
//                    options: [.caseInsensitive, .diacriticInsensitive]
//                ) != nil
                
//                return name.range(of: bread.calculateBread?.recipe ?? "", options:  [.caseInsensitive, .diacriticInsensitive]) != nil
            }
        )
        descriptor.fetchLimit = 1
        let recipe = try store.mainContext.fetch(descriptor).first
                
        guard let recipe else {
            print("No hay receta...muestra ContentUnavailableView")
            return .result(dialog: intentDialog,
                           view: ContentUnavailableView("nada de nada ", systemImage: "leaf", description: Text("nada de nada")))
        }
        
        let view = BreadRecipeView(recipe: recipe)//RecipeSavedDetailView

        print("Hay receta...muestra RecipeSavedDetailView")
        
        return .result(dialog: intentDialog,
                       view: view)
    }
    
}

struct BreadRecipeView: View {
    
    let recipe: BreadUpIngredients
    
    /// Muestra el título en la barra solo cuando el hero sale de vista.
    @State private var showNavTitle = false

    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 32
    
    @ScaledMetric(relativeTo: .largeTitle) private var heroBadgeSize: CGFloat = 76
    
    @ScaledMetric(relativeTo: .body) private var rowIconSize: CGFloat = 15
    
    @ScaledMetric(relativeTo: .body) private var rowBadgeSize: CGFloat = 32

    var body: some View {
        //ScrollView {
        VStack {//spacing: 24
            header
                .onGeometryChange(for: Bool.self) { proxy in
                    // El hero deja de verse cuando su borde inferior
                    // sube por encima del top del scroll.
                    proxy.frame(in: .scrollView).maxY < 10
                } action: { isHidden in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showNavTitle = isHidden
                    }
                }
            ingredientsCard
            if !steps.isEmpty {
                stepsSection
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
        //}
    }
    
    private var header: some View {
      VStack(spacing: 14) {
        Image(systemName: "fork.knife")
          .font(.system(size: heroIconSize, weight: .semibold))
          .foregroundStyle(.white)
          .frame(width: heroBadgeSize, height: heroBadgeSize)
          .background { Circle().fill(.white.opacity(0.22)) }
          .accessibilityHidden(true)

        Text(title)
          .font(.largeTitle.bold())
          .multilineTextAlignment(.center)
          .foregroundStyle(.white)

        if let created = recipe.created {
          Label {
            Text(created, format: .dateTime.day().month(.wide).year())
          } icon: {
            Image(systemName: "calendar")
          }
          .font(.subheadline.weight(.medium))
          .foregroundStyle(.white.opacity(0.92))
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 36)
      .padding(.horizontal, 20)
      .background {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
          .fill(
            LinearGradient(
              colors: [
                Color("HeroTop"),
                Color("HeroBottom"),
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .shadow(
            color: Color("HeroBottom").opacity(0.35),
            radius: 14, x: 0, y: 8)
      }
      .padding(.top, 8)
    }
    
    private var ingredientsCard: some View {
      VStack(alignment: .leading, spacing: 12) {
        sectionTitle("Ingredientes", systemImage: "list.bullet")

        VStack(spacing: 0) {
          ingredientRow(
            icon: "leaf.fill",
            tint: Color("BreadFlour"),
            title: "Harina",
            detail: recipe.flourType.displayName,
            value: "\(recipe.flourQuantity) g")
          Divider().padding(.leading, 60)
          ingredientRow(
            icon: "bubbles.and.sparkles.fill",
            tint: Color("BreadYeast"),
            title: "Levadura",
            detail: nil,
            value: "\(recipe.yeast) g")
          Divider().padding(.leading, 60)
          ingredientRow(
            icon: "drop.fill",
            tint: Color("BreadWater"),
            title: "Agua",
            detail: nil,
            value: "\(recipe.water) ml")
        }
        .padding(.vertical, 4)
        .background {
          RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(.secondarySystemGroupedBackground))
        }
        // Declara la forma del contenedor (radio 20) para que cualquier
        // ConcentricRectangle descendiente calcule su radio de forma concéntrica.
        .containerShape(.rect(cornerRadius: 20))
      }
    }
    
    private func ingredientRow(
      icon: String,
      tint: Color,
      title: String,
      detail: String?,
      value: String
    ) -> some View {
      HStack(spacing: 14) {
        Image(systemName: icon)
          .font(.system(size: rowIconSize, weight: .semibold))
          .foregroundStyle(.white)
          .frame(width: rowBadgeSize, height: rowBadgeSize)
          .background {
            // Concéntrico al contenedor (radio 20); no baja de 9 para que el
            // badge mantenga su redondeo al estar lejos de las esquinas.
            ConcentricRectangle.rect(corners: .concentric(minimum: 9), isUniform: true)
              .fill(tint)
          }
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 2) {
          Text(title).font(.body.weight(.medium))
          if let detail {
            Text(detail).font(.caption).foregroundStyle(.secondary)
          }
        }

        Spacer(minLength: 12)

        Text(value)
          .font(.body.weight(.semibold))
          .foregroundStyle(.secondary)
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 12)
      .accessibilityElement(children: .combine)
    }


    /// Título guardado (en `calculateBread.recipe`); si faltara, un texto por defecto.
    private var title: String {
      let stored =
        recipe.calculateBread?.recipe?
        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
      return stored.isEmpty ? "Receta de pan" : stored
    }
    
    private var steps: [BreadUpStepRecipe] {
      (recipe.calculateBread?.steps ?? []).sorted { $0.order < $1.order }
    }
    
    // MARK: - Pasos
    private var stepsSection: some View {
      VStack(alignment: .leading, spacing: 16) {
        sectionTitle("Elaboración", systemImage: "list.number")
          Text("Numero de pasos que hay \(steps.count)")
        ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
//            Text("Paso \(index + 1)").font(.title)
//            Text("Titulo \(step.title)").font(.title2)
//            Text("Descripcion \(step.descripcion)").font(.title3)
            StepSnippetCard(
            number: index + 1,
            titulo: step.title,
            descripcion: step.descripcion)
        }
      }
    }
    
    // MARK: - Helpers

    private func sectionTitle(_ text: String, systemImage: String) -> some View {
      Label(text, systemImage: systemImage)
        .font(.title2.bold())
        .padding(.leading, 4)
        .accessibilityAddTraits(.isHeader)
    }
}

private struct StepSnippetCard: View {
    
    let number: Int
    let titulo: String
    let descripcion: String

    @ScaledMetric(relativeTo: .title2) private var badgeSize: CGFloat = 46

    private var theme: (top: Color, bottom: Color) {
      Self.palette[(max(number, 1) - 1) % Self.palette.count]
    }

    var body: some View {
      HStack(alignment: .top, spacing: 14) {
        badge
        VStack(alignment: .leading, spacing: 6) {
          Text("Paso \(number)")
            .font(.caption.weight(.bold))
            .textCase(.uppercase)
            .tracking(1.2)
            .foregroundStyle(theme.bottom)
//          Text(titulo)
//            .font(.headline)
//            .foregroundStyle(.primary)
//          Text(descripcion)
//            .font(.subheadline)
//            .foregroundStyle(.secondary)
//            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(18)
      .background(cardBackground)
      .accessibilityElement(children: .combine)
    }

    // MARK: - Subvistas

    private var badge: some View {
      Text("\(number)")
        .font(.title2.weight(.heavy))
        .foregroundStyle(.white)
        .frame(width: badgeSize, height: badgeSize)
        .background {
          Circle().fill(gradient)
        }
        .overlay {
          Circle().strokeBorder(.white.opacity(0.35), lineWidth: 1)
        }
        .shadow(color: theme.bottom.opacity(0.5), radius: 5, x: 0, y: 3)
        .accessibilityHidden(true)
    }

    private var cardBackground: some View {
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .fill(.background)
        .overlay {
          RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(theme.top.opacity(0.10))
        }
        .overlay {
          RoundedRectangle(cornerRadius: 24, style: .continuous)
            .strokeBorder(
              LinearGradient(
                colors: [theme.top.opacity(0.55), theme.bottom.opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ),
              lineWidth: 1
            )
        }
        .shadow(color: theme.bottom.opacity(0.18), radius: 12, x: 0, y: 6)
    }

    private var gradient: LinearGradient {
      LinearGradient(
        colors: [theme.top, theme.bottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    }

    // MARK: - Paleta cálida tipo panadería/horno

    private static let palette: [(top: Color, bottom: Color)] = [
      (Color("Step1Top"), Color("Step1Bottom")),  // ámbar → naranja tostado
      (Color("Step2Top"), Color("Step2Bottom")),  // coral → rojo corteza
      (Color("Step3Top"), Color("Step3Bottom")),  // dorado → bronce
      (Color("Step4Top"), Color("Step4Bottom")),  // verde masa madre
      (Color("Step5Top"), Color("Step5Bottom")),  // lavanda especiada
      (Color("Step6Top"), Color("Step6Bottom")),  // azul cerámica
    ]

}
