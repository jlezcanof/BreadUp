//
//  FoundationModelFramework.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano Fresno on 10/06/2026.
//

import Foundation
import FoundationModels
import Playgrounds

@Generable
enum CategoriasGastos: String, CaseIterable, Identifiable {
    case ocio
    case suscripciones
    case transporte
    case comidas
    case tecnologia
    case salud
    case educacion
    case vivienda
    case otros

    var id: String { rawValue }
}

#Playground {
    let model = SystemLanguageModel.default
    switch model.availability {
    case .available:
        print("Model OK")
    case .unavailable(.appleIntelligenceNotEnabled):
        print("Apple Intelligence no está disponible")
    case .unavailable(.deviceNotEligible):
        print("Este dispositivo NO soporta Apple Intelligence")
    case .unavailable(.modelNotReady):
        print("El modelo aún no está disponible. Intentelo dentro de unos minutos")
    case .unavailable(let error):
        print(error)
    }
    
    let session = LanguageModelSession(model: model) {
        """
        Eres un asistente personal de finanzas domésticas. Hablas en castellano con tono cercano y profesional. Tu única función es ayudar al usuario a entender y organizar sus gastos del hogar.
        REGLAS:
        - Si se pregunta algo que NO sean finanzas, responde amablemente que no es tu ámbito y reconduces.
        - NUNCA des recomendaciones de inversión concretas (acciones, fondos, criptomonedas, etc) Sólo educación financiera general.
        - NUNCA pidas datos bancarios, contraseñas o números de tarjeta.
        """
    }
    
    let total = model.contextSize
    print("Tokens \(total)")
    
    let options = GenerationOptions(temperature: 0.0)
    let newAnswer = try await session.respond(to: "¿Qué tiempo hará mañana en Jaén?", options: options)
    print(newAnswer.content)
    
    let newResponse = try await session.respond(to: "Acabo de pagar 38€ en una comida con clientes. *Es un gasto deducible o no?")
    print(newResponse.content)
    
    let respuesta = try await session.respond(to: "Dame tres consejos breves para ahorrar en gastos del hogar")
    print(respuesta.content)
    
    let categorias: [CategoriasGastos] = [.ocio, .suscripciones]
    
    let prompt = Prompt {
        "En base a las necesidades elegidas por el usuario en las siguientes categorías"
        
        for cat in categorias {
            "- \(cat.rawValue)"
        }
        
        "Dale una recomendación sobre cómo optimizar los gastos de las categorias indicadas"
    }
    
    let respuesta2 = try await session.respond(to: prompt)
    print(respuesta2.content)
    
    // only ios 26.4
//    let totalTokens = try await model.tokenCount(for: session.transcript)
//    print("Total de tokens: \(totalTokens)") let totalTokens = try await model.tokenCount(for: session.transcript)
}
