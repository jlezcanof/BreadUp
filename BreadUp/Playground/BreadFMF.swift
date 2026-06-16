//
//  BreadFMF.swift
//  BreadUp
//
//  Created by Yomismista on 10/06/2026.
//


import Foundation
import FoundationModels
import Playgrounds

func getStreamReceta(receta: BreadRecipe) {
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

func getBreadRecipe(bread: LanguageModelSession.Response<BreadRecipe>) async throws {
    bread.content.pasos.forEach { paso in
        print("\(paso.titulo)")
        print("\(paso.descripcion)")
    }
}
//    if let pasos = bread.content.pasos {
//        //getStepResponse2(pasos: pasos)
//    } else {
//        // No pasos available yet — nothing to do
//        print("No hay pasos disponibles en la receta parcial")
//    }

func getStepsInResponse(pasos: [RecipeStep.PartiallyGenerated]) {
    var step = 1
    for paso in pasos {
        var linea = "> "
        if let titulo = paso.titulo {
            linea += titulo
        }
        linea += "\n"
        if let descripcion = paso.descripcion {
            linea += descripcion
        }
        print(linea)
        step += 1
    }
}

func steps(pasos: Array<RecipeStep>.PartiallyGenerated) {
    for paso in pasos {
        var linea = "> "
        if let titulo = paso.titulo {
            linea += titulo
        }
        if let descripcion = paso.descripcion {
            linea += descripcion
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
    // 3.               Para los títulos usa un vocabulario de panaderia.
    
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
    
//    var totaltokens = try await model.tokenCount(for: session.transcript)
//    print("Tokens consumidos \(totaltokens)")
    
    
    // #############################
//    let options = GenerationOptions(sampling: .greedy, temperature: 0.3, maximumResponseTokens: 150)
    let options = GenerationOptions(temperature: 0.8, maximumResponseTokens: 1200)//800

//    try await streamResponseRecipeStep(session: session, prompt: prompt, options: options)
    try await streamResponseBreadRecipe(session: session, prompt: prompt, options: options)
}

// ################################### ini stream response array recipe step ###############################

func streamResponseRecipeStep(session: LanguageModelSession, prompt: String, options: GenerationOptions) async throws {
    // ini funciona perfectamente, PERO escribe muchas veces lo mismo (por aquello del flujo )
    let stream = session.streamResponse(to: prompt, generating: [RecipeStep].self
                                        , options: options)
    
    //    let recetaResponse = try await stream.collect()
    //    getStreamReceta(receta: recetaResponse.content)
    //    getStepResponse(pasos: stream)
    //    getStreamReceta(receta: stream)
    
    for try await snapshot in stream {
        getStepsInResponse(pasos: snapshot.content)
    }
    print("se acabo el stream response de [RecipeStep]")
    // end funciona perfectamente
    
    // totaltokens = try await model.tokenCount(for: session.transcript)
    // print("\n Tokens consumidos despues del stream Response \(totaltokens)")
    
    let formated = Date.now.formatted(date: .complete, time: .shortened)
    print("Timestamp: \(formated)")
    // #############################
}

// ################################### end stream response array recipe step ###############################


// ################################### ini stream response bread recipe ###############################

//    var breadRecipeContent: BreadRecipe.PartiallyGenerated?
func streamResponseBreadRecipe(session: LanguageModelSession, prompt: String, options: GenerationOptions) async throws {
    let streamBreadRecipe = session.streamResponse(to: prompt, generating: BreadRecipe.self
                                             , options: options)

    // WIP
    let coll = try await streamBreadRecipe.collect().rawContent

    print("coll \(coll)")
        
    //for try await breadRecipe in streamBreadRecipe {
    //        let juan = breadRecipe.content
        
      //  steps(pasos: breadRecipe.content.pasos)
        
    //        print(juan.pasos)
        //print(" \(juan.title) ")
    //        let titulo = juan.title
    //}

    //     for try await partial in stream {
    //         partialCount += 1
    //         self.recipeBreadSequence = partial
    //     }

    //    let breadRecipe = session.streamResponse(to: prompt, generating: BreadRecipe.self,
    //                                             options: options)
    //

    //    for try await partial in breadRecipe.content {
    //
    //    }
    //    var parte: LanguageModelSession
    //    for try await partial in breadRecipe {
        
    //        print(" \(partial.content.) ")
    //    }

    //try await getBreadRecipe(bread: breadRecipe.collect())
    //print("##########################################")
    print("se acabo el strem response de breadRecibe")

}
// ################################### end stream response bread recipe ###############################
