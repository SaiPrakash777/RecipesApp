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
    case favourite = "Favourite"
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
    case cakeIcon = "birthday.cake.fill"
    case bodyIcon = "figure.mind.and.body"
    case flameIcon = "flame.fill"
}
enum GeneralConstants: String{
    case recipe = "Recipes"
    case fav = "Favorites"
    case myFav = "My Favorites"
    case shopping = "Shopping"
    case favRecipesText = "Your Favourite Recipes"
    case favRecipesSubText = "Save recipes you love for easy access and quick meal planning"
}
enum NetworkErrors: LocalizedError {
    case noInternet
    case invalidURL
    case badResponse(statusCode: Int)
    case decodingFailed
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "No internet connection, Please check your network."
        case .invalidURL:
            return "Invalid URL"
        case .badResponse(let statusCode):
            return "Server returned an invalid response (\(statusCode))."
        case .decodingFailed:
            return "Failed to decode the response."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}


