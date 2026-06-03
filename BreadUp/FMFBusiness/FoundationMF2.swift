//
//  FoundationMF2.swift
//  BreadUp
//
//  Created by Yomismista on 01/06/2026.
//
import Playgrounds
import FoundationModels

#Playground("Example two") {
    let model = SystemLanguageModel.default
    switch model.availability {
    case .available:
        print("modelo OK")
    case .unavailable(.appleIntelligenceNotEnabled):
        print("Apple Intelligence not enabled")
    case .unavailable(.deviceNotEligible):
        print("No soporte Apple Inteligence")
    case .unavailable(.modelNotReady):
        print("Modelo aun no disponible, a esperar")
    case .unavailable(let error):
        print(error)
    }
    // máximo de tokens que tiene el modelo
    let totalContextSize = model.contextSize
    print("context size is \(totalContextSize)")
    let session = LanguageModelSession(model: model) {
        """
        Eres un asistente personal de finanzas domésticas. Hablas en castellano con tono cercano y profesional. Tu única función es ayudar al usuario a entender y organizar sus gastos del hogar.
        REGLAS:
        - si se pregunta algo que NO TENGAN NADA QUE VER con finanzas, responde amablemente que NO es tu ámbito y reconduces.
        - Nunca des recomendaciones de inversión concretas (acciones, fondo, criptomonedas, etc..) Solo educación financiera general.
        - Nuna pidas datos bancarios, contraseñas o números de tarjetas
        """
    }
     
    // sampling: .greedy, temperatura: 1.0)
    let options = GenerationOptions(maximumResponseTokens: 10)
    let newResponseOne = try await session.respond(to: "¿Qué tiempo hará mañana en Cuenca?")
    print(newResponseOne.content)
    
    let newResponseTwo = try await session.respond(to: "Acabo de pagar 38€ en una comida con clientes. ¿Es un gasto deducible o no?", options: options)
    print (newResponseTwo.content)
    
    let newResponseThree = try await session.respond(to: "Dame tres consejos breves para ahorrar en gastos del hogar")
    print (newResponseThree.content)
    
    // Para sacarnos los tokens de la transcripcion
//    let totalTokens = try await model.tokenCount(for: session.transcript)
// print("Tokens consumidos : \(totalTokens)")
    
//    let categorias : [CategoriaGastos] = [.ocio, .suscripciones]
}
