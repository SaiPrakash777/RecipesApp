//
//  GeneralConstants.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 10/10/25.
//

import Foundation

enum SortingOptions: String, CaseIterable {
    case name = "Name"
    case cookingTime = "Cooking Time"
    case rating = "Rating"
    case difficulty = "Difficulty"
}
enum FilterOptions: String,CaseIterable{
    case all = "All"
    case vegan = "Vegan"
    case chicken = "Chicken"
    case salad = "Salad"
}
enum ImageIcons: String{
    case forkAndKnifeIcon = "fork.knife.circle.fill"
    case heartIcon = "heart"
    case heartFillIcon = "heart.fill"
    case cartIcon = "cart"
    case cartFillIcon = "cart.fill"
    case magnifyingGlassIcon = "magnifyingglass"
    case clockIcon = "clock"
    case starIcon = "star.fill"
    case arrowsIcon =  "arrow.up.arrow.down.circle.fill"
}
enum GeneralConstants: String{
    case recipe = "Recipes"
    case fav = "Favorites"
    case myFav = "My Favorites"
    case shopping = "Shopping"
    case favRecipesText = "Your Favourite Recipes"
    case favRecipesSubText = "Save recipes you love for easy access and quick meal planning"
}

