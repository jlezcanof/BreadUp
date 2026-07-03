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
        
        let title = recipe.calculateBread?.recipe?.trimmingCharacters(in: .whitespacesAndNewlines)//.whitespaces
        attributes.title = title
        attributes.displayName = title//recipe.calculateBread?.recipe?.trimmingCharacters(in: .whitespaces)
        //let firstStepDescription  = recipe.calculateBread?.steps.first?.descripcion.trimmingCharacters(in: .whitespacesAndNewlines)
        let secondStepDescription = recipe.calculateBread?.steps[1].descripcion.trimmingCharacters(in: .whitespaces)
        
        let typeFlour = recipe.flourType.rawValue
        
        attributes.contentDescription = typeFlour//firstStepDescription....secondStepDescription
        attributes.textContent        = typeFlour // secondStepDescription
        
//        let debugDescription = recipe.calculateBread.debugDescription
//        print("debug description is \(debugDescription)")
        
        print("second step description \(secondStepDescription!)")//prueba
        print("display name \(title!)")//prueba

        // TODO habría que sacar todos los steps y convertirlos a un único texto
        
        //Este es el más importante
        attributes.contentCreationDate = recipe.created ?? .now
        attributes.associateAppEntity(RecipeBreadEntity(id: recipe.id.uuidString,
                                                        title: title ?? "titulin",
                                                        contentSteps: "Harina de \(typeFlour)",
                                                        createdAt: recipe.created ?? .now))

        
        return CSSearchableItem(uniqueIdentifier: recipe.id.uuidString,
                                domainIdentifier: domainIdentifier,
                                attributeSet: attributes)
    }
}

