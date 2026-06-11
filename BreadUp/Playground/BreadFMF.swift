//
//  BreadFMF.swift
//  BreadUp
//
//  Created by Yomismista on 10/06/2026.
//


import Foundation
import FoundationModels
import Playgrounds

@Generable
struct RecetaDePan {
    @Guide(description: "Listado de todos los pasos que tiene que realizar para la receta de pan", .minimumCount(6), .maximumCount(9))
    let pasos: [PasoDeReceta]
}

@Generable
struct PasoDeReceta {
        @Guide(description: "Pequeño título del paso en la receta")
        let titulo: String
    
        @Guide(description: "Descripcion detallada y completa del paso a realizar")
        let descripcion: String
}

func getStreamReceta(receta: RecetaDePan) {
    var step = 1
    for paso in receta.pasos {
        print("Paso \(step)")
//        print("> \(paso.titulo) --  \(paso.descripcion)"
        print("> **\(paso.titulo)** ")
        print("> \(paso.descripcion)")
        print("\n")
        step += 1
    }
}

func getStepResponse(pasos: [PasoDeReceta.PartiallyGenerated]) {
    for paso in pasos {
        var linea = "> "
        if let titulo = paso.titulo {
                    linea += titulo + " -- "
        }
        if let descripcion = paso.descripcion {
//                    linea += "\n"
//                    linea += descripcion// + " -- "
                    linea += descripcion + " -- "
        }

        print(linea)
    }
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
    
//    let total = model.contextSize
//    print("Tokens \(total)")
    
    let instructions =
            """
            Eres un maestro panadero con 40 años de experiencia. Creas recetas de pan
            reales y contrastadas, explicadas con un toque cercano y evocador.

            Reglas:
            1. Responde siempre en castellano.
            2. Usa únicamente los ingredientes y cantidades que te dé el usuario.
               Solo puedes añadir agua o sal si son imprescindibles, indicándolo.
            3. Cada paso tiene un título corto (3 a 5 palabras) y una descripción
               de 2 frases como máximo, con acción concreta, tiempos y temperaturas.
            4. Si las proporciones no permiten hacer un pan viable, dilo al inicio
               y propón el ajuste mínimo necesario.
            5. Si te preguntan algo ajeno a la panadería, responde amablemente que
               solo ayudas con recetas de pan.
            """
    // 3.               Para los títulos usa vocabulario de panaderia.
    
    let session = LanguageModelSession(model: model, instructions: instructions)
    
    session.prewarm()
    
    let prompt =
    """
        Crea una receta de pan casero usando estos ingredientes/cantidades:
        - Agua: 100 mililitros
        - Harina de trigo: 300 gramos
        - Levadura fresca de panaderia: 3 gramos.
    """

//    Responde con un string normal y corriente
//    print("venga informame, vamos no seas vago")
//    let respuesta = try await session.respond(to: prompt)
    //print(respuesta.content)
    
    var totaltokens = try await model.tokenCount(for: session.transcript)
    print("Tokens consumidos \(totaltokens)")
    
    
    // #############################
//    let options = GenerationOptions(sampling: .greedy, temperature: 0.3, maximumResponseTokens: 150)
    let options = GenerationOptions(temperature: 0.8, maximumResponseTokens: 1200)//800

    let stream = session.streamResponse(to: prompt, generating: RecetaDePan.self
                                        , options: options)

//    let recetaResponse = try await stream.collect()
//    getStreamReceta(receta: recetaResponse.content)
//    getStepResponse(pasos: stream)
//    getStreamReceta(receta: stream)
    
    for try await snapshot in stream {
        print(snapshot.content)
//        print("\n")
    }
    
    totaltokens = try await model.tokenCount(for: session.transcript)
    print("\n Tokens consumidos despues del stream Response \(totaltokens)")
    
    let formated = Date.now.formatted(date: .complete, time: .shortened)
    print("Timestamp: \(formated)")
    // #############################
}
