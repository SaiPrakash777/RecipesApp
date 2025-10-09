//
//  UtilsClass.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 09/10/25.
//

import Foundation
import SwiftUI

struct CachedImageView: View {
    @State private var uiImage: UIImage? = nil
    let urlString: String?
    let placeholder: String
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    
    var body: some View {
        ZStack {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Color.black, lineWidth: 1)
                        )
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemGray5))
                    .frame(width: width, height: height)
                    .overlay(
                        Image(systemName: placeholder)
                            .foregroundColor(.gray)
                    )
                    .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Color.black, lineWidth: 1) // black border
                        )
            }
        }
        .onAppear {
            loadImage(from: urlString)
        }
    }
    
    private func loadImage(from urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        // Checks URLCache first
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let cachedImage = UIImage(data: cachedResponse.data) {
            self.uiImage = cachedImage
            print("Image loaded from cache")
            return
        }
        // Fetch image from server
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let response = response, error == nil,
               let image = UIImage(data: data) {
                // Cache the response
                let cachedResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedResponse, for: request)
                DispatchQueue.main.async {
                    self.uiImage = image
                    print("Image downloaded from server")
                }
            }
        }.resume()
    }
}
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
enum GeneralConstants: String{
    case recipe = "Recipes"
    case fav = "Favorites"
    case shopping = "Shopping"
}
