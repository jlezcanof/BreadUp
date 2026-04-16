//
//  Generable.swift
//  BreadUp
//
//  Created by Yomismista on 9/4/26.
//
import FoundationModels
//import Contacts


@Generable
struct StepRecipe : Equatable {
    @Guide(description: "A short title describing a step in a bread-making recipe")
    let nameStep: String
    @Guide(description: "Detailed description of a step in making bread")
    let descriptionStep: String

    // Macro-generated
    static var schema: GenerationSchema {
        GenerationSchema(type: StepRecipe.self, properties: [
            GenerationSchema.Property(name: "nameStep",description: "Name of the step of recipe a bread", type: String.self),
            GenerationSchema.Property(name: "descriptionStep", description: "Detailed description",  type: String.self),
        ])
    }
}

//extension StepRecipe: Generable {
//    init(_ content: GeneratedContent) throws {
//        self.nameStep = try content.value(forProperty: "nameStep")
//        self.descriptionStep = try content.value(forProperty: "descriptionStep")
//    }
//}

@Generable()
struct BreadRecipe {
    
    @Guide(description: "The set of steps that together make it possible to prepare bread dough", .count(8))
    let steps: [StepRecipe]
}

extension BreadRecipe {
    static let exampleRecipeBread = BreadRecipe(steps:  [
        StepRecipe(nameStep: "Mezcla inicial", descriptionStep: "Disuelve la levadura en el agua templada (no caliente). Añade la harina y mezcla hasta integrar."),
        StepRecipe(nameStep: "Reposo corto (autólisis ligera)", descriptionStep: "Deja reposar la mezcla 10–15 minutos. Mejora la hidratación y facilita el amasado."),
        StepRecipe(nameStep: "Añadir sal y amasar", descriptionStep: "Incorpora la sal y amasa durante 10–12 minutos (a mano o máquina) hasta obtener una masa elástica y homogénea."),
        StepRecipe(nameStep: "Primera fermentación (bloque)", descriptionStep: "Deja reposar la masa en un bol tapado durante 1–2 horas a temperatura ambiente, hasta que doble su volumen."),
        StepRecipe(nameStep: "Formado", descriptionStep: "Desgasifica suavemente y da forma de hogaza (tensión superficial en la masa, sin desgarrar)."),
        StepRecipe(nameStep: "Segunda fermentación (prueba)", descriptionStep: "Deja reposar la pieza formada durante 45–60 minutos."),
        StepRecipe(nameStep: "Horneado", descriptionStep:
                  """
                  •    Precalienta el horno a 230 °C
                      •    Haz un corte superficial en la masa
                      •    Hornea:
                      •    10 min a 230 °C con vapor (puedes poner un recipiente con agua)
                      •    25–30 min a 200 °C sin vapor
                      •    Enfría sobre rejilla al menos 1 hora antes de cortar
                  """
                  )
    ]
    )
}
