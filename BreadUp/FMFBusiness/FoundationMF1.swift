//
//  FoundationMF.swift
//  BreadUp
//
//  Created by Yomismista on 28/05/2026.
//

import Foundation
import FoundationModels
import Playgrounds

enum CategoriaGastos: String, CaseIterable {
    case ocio
    case comida
    case suscripciones
}

#Playground("Example One") {
    
    let model = SystemLanguageModel.default
    switch model.availability {
    case .available:
        print("modelo cargado")
    case .unavailable(.appleIntelligenceNotEnabled):
        print("Apple Intelligence not enabled")
    case .unavailable(.deviceNotEligible):
        print("No soporte Apple Inteligence")
    case .unavailable(.modelNotReady):
        print("Modelo aun no disponible, a esperar")
    case .unavailable(let error):
        print(error)
    }
    
    let session = LanguageModelSession(model: model) {
        """
        Eres un asistente personal de finanzas domésticas. Hablas en castellano con tono cercano y profesional. Tu única función es ayudar al usuario a entender y organizar sus gastos del hogar.
        Reglas:
        - si el usuario pregunta algo que not enga que ver con finanzas personales, responsable amablemente que no es tu ámbito y reconduces.
        - NUNC des recomendaciones de inversión concretas (acciones, fondo, criptomonedas, etc..) Solo educación financiera general
        - Nuna pidas datos 
        """
    }
//    let respuesta = try await session.respond(to: "Dame tres pasos para realizar una masa de pan")
//    print(respuesta.content)
    
    let categorias: [CategoriaGastos] = [.comida, .suscripciones, .ocio]
    
    let prompt = Prompt {
        "En base a las necesidades elegidas por el usuario en las siguientes categorías"
        
        for cat in categorias {
            "- \(cat.rawValue)"
        }
        
        "Dale una recomendación sobre como optimizar los gastos de esto"
    }
    
    //forma parte de la conversación, esta dentro de la session
    let newAnswer = try await session.respond(to: prompt)
    print(newAnswer.content)
}
