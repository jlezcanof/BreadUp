//
//  Generable.swift
//  BreadUp
//
//  Created by Yomismista on 9/4/26.
//
import FoundationModels
//import Contacts

@Generable
struct BreadRecipe {
    @Guide(description: "Listado de todos los pasos que tiene que realizar para la receta de pan", .minimumCount(6), .maximumCount(9))
    let pasos: [RecipeStep]
}

@Generable
struct RecipeStep {
        @Guide(description: "Pequeño título del paso en la receta")
        let titulo: String
    
        @Guide(description: "Descripcion detallada y completa del paso a realizar")
        let descripcion: String
}



//
//@Generable
//struct StepRecipe : Equatable {
//    @Guide(description: "A short title describing a step in a bread-making recipe")
//    let nameStep: String
//    @Guide(description: "Detailed description of a step in making bread")
//    let descriptionStep: String
//
//    // Macro-generated
//    static var schema: GenerationSchema {
//        GenerationSchema(type: StepRecipe.self, properties: [
//            GenerationSchema.Property(name: "nameStep",description: "Name of the step of recipe a bread", type: String.self),
//            GenerationSchema.Property(name: "descriptionStep", description: "Detailed description",  type: String.self),
//        ])
//    }
//}

extension RecipeStep {
    static let example = RecipeStep(titulo: "Reposo corto (autólisis ligera)",
                                    descripcion: "Deja reposar la mezcla 10-15 minutos. Mejora la hidratación y facilita el amasado.")
    
    
    static let firstStep = RecipeStep(titulo: "Preparación la masa",
                                    descripcion: "En un bol grande, mezcla la levadura fresca con el agua tibia (aproximadamente 37°C). Déjala reposar durante 5 minutos, o hasta que el líquido esté espumoso y burbujeante.")
    
    
    static let secondStep = RecipeStep(titulo: "Levadura activada",
                                    descripcion: "Coloca la masa en un bol engrasado, tapa con un paño húmedo y déjala reposar en un lugar cálido durante 1 hora. Durante este tiempo, la masa debe duplicarse en tamaño.")
    
      
    static let threeStep = RecipeStep(titulo: "Primera levadura",
                                    descripcion: "Después de 1 hora, engrasa un molde para pan y coloca la masa dentro. Deja reposar nuevamente durante 30 minutos, hasta que la masa haya crecido un poco más.")
    
    static let fourStep = RecipeStep(titulo: "Formar el pan",
                                    descripcion: "Divide la masa en dos partes, si se desea hacer pan de dos piezas. Aplasta cada parte en forma de disco y luego dóblalas en tres lados, formando un cilindro. Coloca el cilindro en el molde preparado.")
    
    static let fiveStep = RecipeStep(titulo: "Segunda levadura",
                                    descripcion: "Tapa el molde con un paño húmedo y deja reposar por 45 minutos, o hasta que la masa cubra el molde.")
    
    static let sixStep = RecipeStep(titulo: "Hornear el pan",
                                    descripcion: "Precalienta el horno a 220°C (428°F). Antes de hornear, haz unos cortes en la superficie del pan con un cuchillo afilado. Hornea el pan durante 20-25 minutos, o hasta que esté dorado y crujiente.")
    
    static let sevenStep = RecipeStep(titulo: "Incorporar harina",
                                    descripcion: "Agrega la harina de trigo a la mezcla de levadura y agua. Amasa suavemente con las manos o un tenedor hasta formar una masa homogénea. La masa debe ser suave y elástica, sin pegajosa.")
    
    static let eightStep = RecipeStep(titulo: "Levadura activada",
                                    descripcion: "Coloca la masa en un bol engrasado, tapa con un paño húmedo y déjala reposar en un lugar cálido durante 1 hora. Durante este tiempo, la masa debe duplicarse en tamaño.")
    
    static let nineStep = RecipeStep(titulo: "Formar el pan",
                                    descripcion: "Divide la masa en dos partes, si se desea hacer pan de dos piezas. Aplasta cada parte en forma de disco y luego dóblalas en tres lados, formando un cilindro. Coloca el cilindro en el molde preparado.")
    
    static let tenStep = RecipeStep(titulo: "Incorporar harina", descripcion: "Agrega la harina de trigo a la mezcla de levadura y agua. Amasa suavemente con las manos o un tenedor hasta formar una masa homogénea. La masa debe ser suave y elástica, sin pegajosa.")
    
}


//extension StepRecipe: Generable {
//    init(_ content: GeneratedContent) throws {
//        self.nameStep = try content.value(forProperty: "nameStep")
//        self.descriptionStep = try content.value(forProperty: "descriptionStep")
//    }
//}
