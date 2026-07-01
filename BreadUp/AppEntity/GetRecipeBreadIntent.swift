//
//  GetRecipeBreadIntent.swift
//  BreadUp
//
//  Created by Jose Manuel lezcano Fresno on 01/07/2026.
//
import AppIntents
import SwiftUI
import SwiftData

//TODO WIP
struct GetRecipeBreadIntent: AppIntent {
    static let title: LocalizedStringResource = "Consulta receta de pan en BreadUp"
    
    static let description = IntentDescription("Busca una receta de pan por el nombre", categoryName: "Recetas")
    
    @Parameter(title: "Nombre de la receta" ,requestValueDialog: "Nombre de la receta") var name: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Busca receta de pan por el nombre \(\.$name)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {// & ShowsSnippetView
        let intentDialog = IntentDialog("Buscando en BreadUp")
        let store = AppModelStore.shared
        var descriptor = FetchDescriptor<BreadUpIngredients>(predicate: #Predicate {bread in bread.calculateBread?.recipe == name})
        descriptor.fetchLimit = 1
        
        let recipe = try store.mainContext.fetch(descriptor).first
                
        guard let recipe else {
            return .result(dialog: intentDialog,
                           view: ContentUnavailableView("nada de nada ", image: "leaf", description: Text("nada de nada")))
        }
        
        return .result(dialog: intentDialog,
                       view: RecipeSavedDetailView(recipe: recipe))
        
    }
    
}
