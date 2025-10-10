//
//  RecipesDM.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 09/10/25.
//

import Foundation

struct RecipesDM : Codable {
    let recipes : [Recipes]
    let total : Int?
    let skip : Int?
    let limit : Int?
    init(recipes: [Recipes], total: Int?, skip: Int?, limit: Int?) {
        self.recipes = recipes
        self.total = total
        self.skip = skip
        self.limit = limit
    }
}
struct Recipes : Codable {
    let id : Int?
    let name : String?
    let ingredients : [String]?
    let instructions : [String]?
    let prepTimeMinutes : Int?
    let cookTimeMinutes : Int?
    let servings : Int?
    let difficulty : String?
    let cuisine : String?
    let caloriesPerServing : Int?
    let tags : [String]?
    let userId : Int?
    let image : String?
    let rating : Double?
    let reviewCount : Int?
    let mealType : [String]?
}
