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
            urlCacheloadImage(from: urlString)
        }
    }
    
    private func urlCacheloadImage(from urlString: String?) {
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
struct ListView: View {
    let name: String
    let cookTime: Int
    let servings: Int
    let rating: Double
    let cuisine: String
    let difficulty: String?
    let imageURL: String?
    @Binding var isFavorite: Bool
    let onFavTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CachedImageView(
                urlString: imageURL,
                placeholder: "photo",
                width: 60,
                height: 60,
                cornerRadius: 8
            )
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(name)
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        onFavTap()
                        isFavorite.toggle()
                    }) {
                        Image(systemName: isFavorite ? ImageIcons.heartFillIcon.rawValue : ImageIcons.heartIcon.rawValue)
                            .foregroundColor(isFavorite ? .red : .black)
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        Image(systemName: ImageIcons.clockIcon.rawValue)
                            .foregroundColor(.gray)
                        Text("\(cookTime) min")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Text("•")
                    HStack(spacing: 3) {
                        Image(systemName: ImageIcons.forkAndKnifeIcon.rawValue)
                            .foregroundColor(.gray)
                        Text("\(servings) servings")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .font(.caption)
                .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: ImageIcons.starIcon.rawValue)
                            .foregroundColor(.orange)
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline)
                    }

                    Text(cuisine)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(6)

                    if let difficulty {
                        Text(difficulty)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ListView(name: "Recipe name", cookTime: 40, servings: 5, rating: 4.0, cuisine: "Indian", difficulty: "Meduim", imageURL: "", isFavorite: .constant(false), onFavTap: {print("Tapped ")})
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
