//
//  RecipeBreadIntents.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano Fresno on 04/06/2026.
//

import SwiftUI
import AppIntents

@available(*, deprecated, renamed: "GetRecipeBreadIntent", message: "No vamos a tener un app intentar para generar recetas, no tiene sentido")
struct CreateRecipeBreadIntent: AppIntent {
    
    static let title: LocalizedStringResource = "Crear receta de pan en BreadUp"
    
    static let description = IntentDescription("Genera una receta de pan en BreadUp, con tipo de harina, cantidad de harina, cantidad de agua y levadura",
    categoryName: "Recetas")
    
    @Parameter(title: "Tipo de harina", default: .wheat ,requestValueDialog: "Tipo de harina") var flourType: FlourType
    @Parameter(title: "Cantidad de harina", requestValueDialog: "¿Cantidad de harina (125 - 400) gramos ?") var flourQuantity: Int// picker de valores a seleccionar
//    in: 125...400,
//    step: 25
    @Parameter(title: "agua", requestValueDialog: "¿Cantidad de agua (125 - 500) gramos ?") var water: Int
//    in: 125...500,
//    step: 25
    @Parameter(title: "levadura", requestValueDialog: "¿Cantidad de levadura (5 - 50) gramos?") var yeast: Int
//    in: 5...50,
//    step: 5,
    
    // expongo la accion al atajo
    static var parameterSummary: some ParameterSummary {
        Summary("Generar receta para una harina de tipo \(\.$flourType), cantidad \(\.$flourQuantity), agua \(\.$water) ml, y \(\.$yeast) gramos de levadura")
    }
    
    @MainActor // / & ProvidesDialog & ShowsSnippetView
    func perform() async throws -> some IntentResult {
        let intentDialog = IntentDialog("Generado en BreadUp")// Guardado
        return .result(dialog: intentDialog,
                       view: BreadRecipeSnippetView(flourType: flourType, flourQuantity: flourQuantity, water: water, yeast: yeast))
    }
    
    //     static var openAppWhenRun: Bool { get }//true
    
    //     static var supportedModes: IntentModes { get }

}


struct BreadRecipeSnippetView: View {
    let flourType: FlourType
    
    let flourQuantity: Int//Enum
    
    let water: Int//Enum
    
    let yeast: Int//Enum 

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(flourType.rawValue)
                .font(.body)
                .lineLimit(2)

            Text(flourQuantity.description)
                .font(.body)
                .lineLimit(4)
            
            Text(water.description)
                .font(.body)
                .lineLimit(4)
            
            Text(yeast.description)
                .font(.body)
                .lineLimit(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
    }
}


//struct BreadRecipeShortcuts: AppShortcutsProvider {
//    
//    static var appShortcuts: [AppShortcut] {
//        AppShortcut(intent: CreateRecipeBreadIntent(),
//                    phrases:  ["idioma por defecto de la aplicación \(.applicationName)",
//                               "Crea una receta con display name \(.applicationName)",
//                               "Anotado con \(.applicationName)"
//                              ],
//                    shortTitle: "Receta rápida",
//                    // LocalizedStringResource(stringLiteral: "pan para pan pan pan")
//                    systemImageName: "cooktop.fill")
//    }
//    
//    
//}
