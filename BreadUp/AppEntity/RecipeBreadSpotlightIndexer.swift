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
        
        let title = recipe.calculateBread?.recipe?.trimmingCharacters(in: .whitespacesAndNewlines)
        attributes.title = title
        attributes.displayName = recipe.calculateBread?.recipe?.trimmingCharacters(in: .whitespaces)
        let firstStepDescription = recipe.calculateBread?.steps.first?.descripcion.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let typeFlour = recipe.flourType.rawValue
        
        attributes.contentDescription = firstStepDescription
        attributes.textContent        = typeFlour
        let debugDescription = recipe.calculateBread.debugDescription
        print("debug description is \(debugDescription)")
        
        //Este es el más importante
        attributes.contentCreationDate = recipe.created ?? .now
        attributes.associateAppEntity(RecipeBreadEntity(id: recipe.id.uuidString,
                                                        title: title ?? "",
                                                        subtitle: typeFlour,
                                                        createdAt: recipe.created ?? .now))

        
        return CSSearchableItem(uniqueIdentifier: recipe.id.uuidString,
                                domainIdentifier: domainIdentifier,
                                attributeSet: attributes)
    }
}

