//
//  AppShortcutsProvider.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano Fresno on 01/07/2026.
//
import AppIntents

struct BreadRecipeShortcuts: AppShortcutsProvider {
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: GetRecipeBreadIntent(),//CreateRecipeBreadIntent()
                    phrases:  ["idioma por defecto de la aplicación \(.applicationName)",
                               "Crea una receta con display name \(.applicationName)",
                               "Anotado con \(.applicationName)"
                              ],
                    shortTitle: "Receta rápida",
                    // LocalizedStringResource(stringLiteral: "pan para pan pan pan")
                    systemImageName: "cooktop.fill")
    }
    
    
}
