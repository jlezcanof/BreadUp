//
//  RecipeBreadSpotlightIndexer.swift
//  BreadUp
//
//  Created by Yomismista on 04/06/2026.
//
import AppIntents
import CoreSpotlight
import Foundation
import UniformTypeIdentifiers

@MainActor
enum RecipeBreadSpotlightIndexer {
     
    private static let domainIdentifier = "Breadup"
    private static let index = CSSearchableIndex(name: "BreadUp")
    
    static func index (recipe: BreadUpIngredients) async throws {
        try await index.indexSearchableItems([searchableItem(for: recipe)])
    }
    
    static func index (recipes: [BreadUpIngredients]) async throws {
        let items = recipes.map {searchableItem(for: $0)}
        try await index.indexSearchableItems(items)
    }
    
    private static func searchableItem(for recipe: BreadUpIngredients) -> CSSearchableItem {
        let attributes = CSSearchableItemAttributeSet(contentType: .text)
        
        attributes.title = recipe.calculateBread?.recipe?.trimmingCharacters(in: .whitespacesAndNewlines)
        attributes.displayName = "Display name"
        attributes.contentDescription = recipe.calculateBread.debugDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        attributes.textContent = "textcontent"
        attributes.contentCreationDate = Date()
        attributes.associateAppEntity(RecipeBreadEntity(id: recipe.id.uuidString,
                                                        title: "recipe.calculateBread?.recipe!",
                                                        subtitle: "recipe.calculateBread?.recipe!",
                                                        createdAt: recipe.created ?? Date()))

        
        return CSSearchableItem(uniqueIdentifier: recipe.id.uuidString,
                                domainIdentifier: domainIdentifier,
                                attributeSet: attributes)
    }
}

// Usamos enum para poder invocarse desde cuando lado SIN necesidad de crear una instancia (y es ó esto ó un patrón singleton)
