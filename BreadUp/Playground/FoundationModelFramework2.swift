//
//  FoundationModelFramework2.swift
//  BreadUp
//
//  Created by Yomismista on 10/06/2026.
//
import Foundation
import FoundationModels
import Playgrounds

@Generable
struct Gastos {
    @Guide(description: "Descripción breve del gasto en Castellano")
    let descripcion: String
    @Guide(description: "Importe en euros, importe positivo")
    let importe: Double
    @Guide(description: "Categoría que mejor encaje con el gasto")
    let categoria: CategoriasGastos
    @Guide(description: "True si parece un gasto deducible en impuestos")
    let deducible: Bool
}

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

#Playground {
    let session = LanguageModelSession() {
        """
        Eres un asistente financiero que es capaz de extraer información estructurada de gastos del hogar y financieros de descripciones en lenguaje natura. Responde SOLO con los datos solicitados, sin texto adicional.
        """
    }
    
    let stream = session.streamResponse(to: "Esta mañana he gastado 5€ en un café en Starbuck, luego 38€ en una comida con clientes, luego he pasado por la Apple Store y he pillado el último MacBook Neo por 799€, le he devuelto a Juan los 10€ que le debía y ya, al volver a casa, he echado gasolina al coche por 60€.",
                                        generating: [Gastos].self)
    
    
    for try await snapshot in stream {
        getResponse(gastos: snapshot.content)
    }
}
