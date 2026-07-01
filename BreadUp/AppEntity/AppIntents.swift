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
        var descriptor = FetchDescriptor<BreadUpIngredients>(predicate: #Predicate { bread in
            bread.calculateBread?.recipe == name
        })
        
//        guard let title = bread.calculateBread?.recipe else {
//            return false
//        }
//        return title.range(of: name, options: [.caseInsensitive, .diacriticInsensitive] ) != nil
        
        descriptor.fetchLimit = 1
        let recipe = try store.mainContext.fetch(descriptor).first
                
        guard let recipe else {
            print("No hay receta...muestra ContentUnavailableView")
            return .result(dialog: intentDialog,
                           view: ContentUnavailableView("nada de nada ", systemImage: "leaf", description: Text("nada de nada")))
        }

        print("Hay receta...muestra RecipeSavedDetailView")
        return .result(dialog: intentDialog,
                       view: RecipeSavedDetailView(recipe: recipe))
    }
    
}
//struct BreadRecipeSnippetView: View {
//    let flourType: FlourType
//    
//    let flourQuantity: Int//Enum
//    
//    let water: Int//Enum
//    
//    let yeast: Int//Enum
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(flourType.rawValue)
//                .font(.body)
//                .lineLimit(2)
//
//            Text(flourQuantity.description)
//                .font(.body)
//                .lineLimit(4)
//            
//            Text(water.description)
//                .font(.body)
//                .lineLimit(4)
//            
//            Text(yeast.description)
//                .font(.body)
//                .lineLimit(4)
//        }
//        .padding()
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(.background.secondary, in: .rect(cornerRadius: 16))
//    }
//}
