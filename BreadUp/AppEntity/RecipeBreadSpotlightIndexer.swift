//
//  RecipeBreadSpotlightIndexer.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano Fresno on 04/06/2026.
//
import AppIntents
import CoreSpotlight
import Foundation

@MainActor
enum RecipeBreadSpotlightIndexer {
     
    private static let domainIdentifier = "breadup"
    private static let index = CSSearchableIndex(name: "BreadUp")
    
    static func delete(recipe: BreadUpIngredients) async throws {
        let searchableItem = searchableItem(for: recipe)
        try await index.deleteSearchableItems(withIdentifiers: [searchableItem.uniqueIdentifier])
    }
    
    static func index (recipe: BreadUpIngredients) async throws {
        try await index.indexSearchableItems([searchableItem(for: recipe)])
    }
    
    // Actualizacíon en lotes
    static func index (recipes: [BreadUpIngredients]) async throws {
        let items = recipes.map {searchableItem(for: $0)}
        try await index.indexSearchableItems(items)
    }
    
    private static func searchableItem(for recipe: BreadUpIngredients) -> CSSearchableItem {
        let attributes = CSSearchableItemAttributeSet(contentType: .plainText)
        
        let title = recipe.calculateBread?.recipe?.trimmingCharacters(in: .whitespacesAndNewlines)//.whitespaces
        attributes.title = title
        attributes.displayName = title
        
        let firstStepDescription = recipe.calculateBread?.steps.filter {$0.order == 0}.first?.descripcion.trimmingCharacters(in: .whitespacesAndNewlines)
                        
        attributes.contentDescription = firstStepDescription
        attributes.textContent        = firstStepDescription
        
        var contentSteps = "Pasos de la receta"
        
        recipe.calculateBread?.steps.sorted {$0.order < $1.order}.forEach { step in
            contentSteps += "\n\n- ** Paso \(step.order)"
            contentSteps += "\n  - Título: \(step.title)"
            contentSteps += "\n  - Descripcion: \(step.descripcion)"
        }
        
        //Este es el más importante
        attributes.contentCreationDate = recipe.created ?? .now
        attributes.associateAppEntity(RecipeBreadEntity(id: recipe.id.uuidString,
                                                        title: title ?? "titulin",
                                                        contentSteps: contentSteps,
                                                        createdAt: recipe.created ?? .now))

        
        return CSSearchableItem(uniqueIdentifier: recipe.id.uuidString,
                                domainIdentifier: domainIdentifier,
                                attributeSet: attributes)
    }
}

// MARK: - Costura de indexado (inyectable)

/// Abstracción del indexado de recetas. Existe como costura de diseño para
/// poder inyectar en `BreadCalculatorVM` un doble de test que no toque
/// `CSSearchableIndex` (efecto de sistema) ni acceda a la instancia `@Model`
/// (que un `ModelContext` en memoria destruye al resetearse).
///


@MainActor
protocol RecipeIndexing {
    func index(recipe: BreadUpIngredients) async throws
    func delete(recipe: BreadUpIngredients) async throws
}

/// Implementación real por defecto: delega en `RecipeBreadSpotlightIndexer`.
@MainActor
struct SpotlightRecipeIndexer: RecipeIndexing {
    
    func index(recipe: BreadUpIngredients) async throws {
        try await RecipeBreadSpotlightIndexer.index(recipe: recipe)
    }
    
    func delete(recipe: BreadUpIngredients) async throws {
        try await RecipeBreadSpotlightIndexer.delete(recipe: recipe)
    }
}

