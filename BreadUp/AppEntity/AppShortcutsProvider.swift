//
//  AppShortcutsProvider.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano Fresno on 01/07/2026.
//
import AppIntents

struct BreadRecipeShortcuts: AppShortcutsProvider {
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: GetRecipeBreadIntent(),
                    phrases:  [
                        "idioma por defecto de la aplicación \(.applicationName)",
                               "Obtiene una receta con display name \(.applicationName)",
                               "Anotado con \(.applicationName)"//,
//                                "Busca una receta "
                              ],
                    shortTitle: "Obtener receta",
                    // LocalizedStringResource(stringLiteral: "pan para pan pan pan")
                    systemImageName: "cooktop.fill")
    }
}
