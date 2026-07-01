//
//  RecipeBreadEntity.swift
//  BreadUp
//
//  Created by Yomismista on 04/06/2026.
//
import Foundation
import SwiftData
import AppIntents
//import UniformTypeIdentifiers
//import CoreSpotlight

struct RecipeBreadEntity: AppEntity, IndexedEntity {
    
    static let defaultQuery = RecipeBreadQuery()
    
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Recetas de pan de BreadUp")
        
    let id: String
    let title: String
    let subtitle: String
    let createdAt: Date
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: title),
                              subtitle: LocalizedStringResource(stringLiteral: subtitle))
    }
}

struct RecipeBreadQuery: EntityQuery {

    @MainActor func entities(for identifiers: [RecipeBreadEntity.ID]) async throws -> [RecipeBreadEntity] {
        let descriptor = FetchDescriptor<BreadUpIngredients>(predicate: #Predicate {bread in identifiers.contains(bread.id.uuidString)})
        let recipes = try AppModelStore.shared.mainContext.fetch(descriptor)
        // TODO
//        print("\(recipes)")
        // recuperamos todo y filtramos
//        return recipes.filter { identifiers.contains($0.id.uuidString) }.map(\.toEntity)
        return recipes.map(\.toEntity)
//        return []
    }

    @MainActor func suggestedEntities() async throws -> [RecipeBreadEntity] {
        // TODO
        var descriptor = FetchDescriptor<BreadUpIngredients>(sortBy: [SortDescriptor(\.created, order: .reverse)])
        descriptor.fetchLimit = 5
        let recipes = try AppModelStore.shared.mainContext.fetch(descriptor)
        print("\(recipes)")
        return recipes.map(\.toEntity)
//        return []
    }
}
