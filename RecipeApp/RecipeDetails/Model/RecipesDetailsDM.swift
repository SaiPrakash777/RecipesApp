//
//  RecipesDetailsDM.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 10/10/25.
//

import Foundation

struct RecipesDetailsDM : Codable {
    let recipes : [Recipes]?
    let total : Int?
    let skip : Int?
    let limit : Int?
}

