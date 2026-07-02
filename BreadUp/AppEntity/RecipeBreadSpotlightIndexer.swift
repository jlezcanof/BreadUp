//
//  RecipeBreadSpotlightIndexer.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano Fresno on 04/06/2026.
//
import AppIntents
import CoreSpotlight
import Foundation
//import UniformTypeIdentifiers

@MainActor
enum RecipeBreadSpotlightIndexer {
     
    private static let domainIdentifier = "breadup"
    private static let index = CSSearchableIndex(name: "BreadUp")
    
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
        
        attributes.title = recipe.calculateBread?.recipe?.trimmingCharacters(in: .whitespacesAndNewlines)
        attributes.displayName = recipe.calculateBread?.recipe?.trimmingCharacters(in: .whitespaces)//"Display name"
        attributes.contentDescription = recipe.calculateBread?.steps.first?.descripcion.trimmingCharacters(in: .whitespacesAndNewlines)
//        attributes.contentDescription = recipe.calculateBread.debugDescription.trimmingCharacters(in: .whitespacesAndNewlines)
//        attributes.textContent = "textcontent"
        
        //Este es el más importantes
        attributes.contentCreationDate = recipe.created ?? .now
        attributes.associateAppEntity(RecipeBreadEntity(id: recipe.id.uuidString,
                                                        title: "recipe.calculateBread?.recipe!",
                                                        subtitle: "recipe.calculateBread?.recipe!",
                                                        createdAt: recipe.created ?? .now))

        
        return CSSearchableItem(uniqueIdentifier: recipe.id.uuidString,
                                domainIdentifier: domainIdentifier,
                                attributeSet: attributes)
    }
}

// Usamos enum para poder invocarse desde cuando lado SIN necesidad de crear una instancia (y es ó esto ó un patrón singleton)
