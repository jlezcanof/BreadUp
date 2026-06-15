//
//  BreadUpApp.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 25/3/26.
//

import SwiftUI
import SwiftData
import FoundationModels

@MainActor
enum AppModelStore {
    static let shared: ModelContainer = {
        do {
            return try ModelContainer(for: BreadUpIngredients.self, migrationPlan: BreadUpMigrationPlan.self)
        } catch {
            fatalError("No se puede crear la base de datos")
        }
    }()
}

@main
struct BreadUpApp: App {
    
    @State private var vm = BreadCalculatorVM()
    let container = AppModelStore.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    vm.initVM()
                }
                .environment(vm)
        }
        .modelContainer(container)
//        WindowGroup {
//            PruebaFoundationModels(session2: LanguageModelSession())
//        }
        
    }
}
