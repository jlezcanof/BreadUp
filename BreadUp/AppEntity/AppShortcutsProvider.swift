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
                               "Obtiene una receta en \(.applicationName)",
                               "Busca una receta a partir del nombre en \(.applicationName)"
                    ],
                    shortTitle: "Obtener receta",
                    systemImageName: "leaf.arrow.trianglehead.clockwise")
    }
}
