//
//  FavouritesView.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 10/10/25.
//

import SwiftUI

struct FavouritesView: View {
    let name: String
    let cookTime: Int
    let servings: Int
    let rating: Double
    let cuisine: String
    let difficulty: String?
    let imageURL: String?
    let isFavorite: Bool
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
                    Button(action: onFavTap) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .black)
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 8) {
                    Label("\(cookTime) min", systemImage: "clock")
                        .labelStyle(.iconOnly)
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("•")

                    Label("\(servings) servings", systemImage: "fork.knife")
                        .labelStyle(.iconOnly)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
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
    FavouritesView(name: "", cookTime: 0, servings: 0, rating: 0.0, cuisine: "", difficulty: "", imageURL: "", isFavorite: false, onFavTap: {print("Tapped ")})
}
