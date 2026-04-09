//
//  Generable.swift
//  BreadUp
//
//  Created by Yomismista on 9/4/26.
//

import FoundationModels

@Generable()
struct SearchSuggestions {
    
    @Guide(description: "A list of suggested search terms", .count(1))//Una receta de como hacer pan
    var searchTerms: [String]  
}


@Generable()
struct Pan {
    var consejos: String
}
