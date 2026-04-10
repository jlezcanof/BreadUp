//
//  BreadUPSchemaV2.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 8/4/26.
//
import Foundation
import SwiftData

enum BreadUpSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(2, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        []
    }
    
    // TODO a los ingredientes le vamos a añadir la sal..
    
    //y en la receta sólo vamos a guardar el tiempo de cocción y temperatura...y la fecha que se han guardado..
}
