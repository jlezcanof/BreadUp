//
//  RecipeBreadIntents.swift
//  BreadUp
//
//  Created by Yomismista on 04/06/2026.
//

import SwiftUI
import AppIntents

struct CreateRecipeBreadIntent: AppIntent {
    
    static let title: LocalizedStringResource = "Crear receta de pan en BreadUp"
    
    static let description = IntentDescription("Guardar una receta rapida de pan en BreadUp, con harina, mantequilla, azúcar y sal",
    categoryName: "Recetas")
    
    @Parameter(title: "Texto", requestValueDialog: "¿qué quieres que BreadUp recuerde?") var text: String
    @Parameter(title: "Tipo de harina", requestValueDialog: "¿Conque tipo de harina?") var category: String
    
//    @ParameterSummary(<#T##IntentDialog?#>, alwaysConfirm: <#T##Bool#>)
    static var parameterSummary: some ParameterSummary {
        Summary("Anotar \(\.$text) como \(\.$category) con el contenido ")
    }
    
    func perform() async throws -> some IntentResult {
        let intentDialog = IntentDialog("Guardado en BreadUp")
        return .result(dialog: intentDialog, view: BreadRecipeSnippetView(text: text, content: category))
    }
}

struct BreadRecipeSnippetView: View {
    let text: String
    let content: String
//    let category: NoteCategoryValue

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
//            Label(category.localizedTitle, systemImage: category.symbolName)
//                .font(.caption.weight(.semibold))
//                .foregroundStyle(.secondary)

            Text(text)
                .font(.body)
                .lineLimit(2)

            Text(content)
                .font(.body)
                .lineLimit(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
    }
}


struct BreadRecipeShortcuts: AppShortcutsProvider {
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: CreateRecipeBreadIntent(),
                    phrases:  ["idioma por defecto de la aplicación \(.applicationName)",
                               "Crea una receta con display name \(.applicationName)",
                               "Anotado con \(.applicationName)"
                              ],
                    shortTitle: "Receta rápida",
                    // LocalizedStringResource(stringLiteral: "pan para pan pan pan")
                    systemImageName: "cooktop.fill")
    }
    
    
}
