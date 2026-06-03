//
//  FoundationModelMF3.swift
//  BreadUp
//
//  Created by Yomismista on 01/06/2026.
//
import Foundation
import FoundationModels
import Playgrounds

@Generable
enum CategoriaGastos2: String, CaseIterable {
    case ocio
    case comidas
    case suscripciones
    case transporte
    case tecnologia
    case salud
    case educacion
    case vivienda
    case otros
}

@Generable
struct Gastos {
    @Guide(description: "Descripción breve del gasto, en castellano")
    let descripcion: String
    
    @Guide(description: "Importe en euros, número positivo")
    let importe: Double
    
    @Guide(description: "Categoría que mejor encaje con el gasto")
    let categoria: CategoriaGastos2
    
    @Guide(description: "True si para un gasto deducible en impuestos")
    let deducible: Bool
}

#Playground("Generable gastos"){
    let session = LanguageModelSession() {
        """
        Eres un asistente financiero que es capaz de extraer información estructurada de gastos del hogar y financieros de descripciones en lenguaje natural. Response SOLO con los datos solicitados, sin texto adicional.
        """
    }
    
    let respuesta = try await session.respond(to: "Esta mañana he gastado 5€ en un café en Starbucks, luego 38€ en una comida con clientes, luego he pasado por la Apple Store y he pillado el último MacBook Neo por 799€, le he devuelvo a Juan los 10€ que le debía y ya, al volver a casa, he echado gasolina al coche por 60€.", generating:  [Gastos].self)
    
    //    print(respuesta.content)
    
    let gastos = respuesta.content
    
    print(" DESCRIPCION      IMPORTE      DEDUCIBLE")
    for gasto in gastos {
        print("- \(gasto.descripcion): \(gasto.importe)€ en (\(gasto.categoria.rawValue)) -> \(gasto.deducible ? "Sí" : "No")")
    }
    
    print(gastos)
    
    
}
