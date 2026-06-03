
//
//  FoundationModelMF4.swift
//  BreadUp
//
//  Created by Yomismista on 01/06/2026.
//
import Foundation
import FoundationModels
import Playgrounds

// NO se usa
@Generable
struct ListaGastos {
    @Guide(description: "Lista de gastos")
    let gastos: [Gastos]
}

func getResponse(gastos: [Gastos.PartiallyGenerated]) {
    for gasto in gastos {
        var linea = "> "
        if let descripcion = gasto.descripcion {
            linea += descripcion + " -- "
        }
        if let importe = gasto.importe {
            linea += "\(importe)€, "
        }
        if let categoria = gasto.categoria {
            linea += categoria.rawValue + " ("
        }
        if let deducible = gasto.deducible {
            linea += deducible ? "Si": "No" + ")"
        }
        print(linea)
    }
}

func gestionarDatos() async throws {
    let session = LanguageModelSession() {
        """
        Eres un asistente financiero que es capaz de extraer información estructurada de gastos del hogar y financieros de descripciones en lenguaje natural. Response SOLO con los datos solicitados, sin texto adicional.
        """
    }
    
    let stream = session.streamResponse(to: "Esta mañana he gastado 5€ en un café en Starbucks, luego 38€ en una comida con clientes, luego he pasado por la Apple Store y he pillado el último MacBook Neo por 799€, le he devuelvo a Juan los 10€ que le debía y ya, al volver a casa, he echado gasolina al coche por 60€.", generating:  [Gastos].self)
  
    for try await snapshot in stream {
        getResponse(gastos: snapshot.content)
    }
}

#Playground("Generable gastos"){
    
//        let session = LanguageModelSession() {
//            """
//            Eres un asistente financiero que es capaz de extraer información estructurada de gastos del hogar y financieros de descripciones en lenguaje natural. Response SOLO con los datos solicitados, sin texto adicional.
//            """
//        }
//        
//        let stream = try await session.streamResponse(to: "Esta mañana he gastado 5€ en un café en Starbucks, luego 38€ en una comida con clientes, luego he pasado por la Apple Store y he pillado el último MacBook Neo por 799€, le he devuelvo a Juan los 10€ que le debía y ya, al volver a casa, he echado gasolina al coche por 60€.", generating:  [Gastos].self)
//      
//        for try await snapshot in stream {
//            getResponse(gastos: snapshot.content)
//        }
    try await gestionarDatos()
}
