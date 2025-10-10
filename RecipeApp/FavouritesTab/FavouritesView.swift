//
//  FavouritesView.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 10/10/25.
//

import SwiftUI

struct FavouritesView: View {
    @State var recipesCoreDataInstance = [RecipesEntity]()
    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 5)
                if recipesCoreDataInstance.count > 0 {
                    ScrollView {
                        Divider()
                        LazyVStack(spacing: 10) {
                            ForEach(recipesCoreDataInstance, id: \.self) { recipe in
                                NavigationLink(destination: RecipeDetailsView(recipesDetailsVM: RecipesDetailsVM(networkService: NetworkClass()), recipeName: recipe.recipeName ?? "")) {
                                    ListView(
                                        name: recipe.recipeName ?? "",
                                        cookTime: Int(recipe.cookTimeMinutes),
                                        servings: Int(recipe.servings),
                                        rating: recipe.ratings,
                                        cuisine: recipe.cuisine ?? "",
                                        difficulty: recipe.difficultyStatus ?? "",
                                        imageURL: recipe.recipeImage ?? "",
                                        isFavorite: .constant(true),
                                        onFavTap: {
                                            DBManager.sharedInstance.deleteRecipeRecord(recipeId: Int(recipe.recipeId))
                                            if let index = recipesCoreDataInstance.firstIndex(of: recipe) {
                                                recipesCoreDataInstance.remove(at: index)
                                            }
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                                Divider()
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Spacer()
                    VStack {
                        Image(systemName: ImageIcons.heartIcon.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        Text.updatedText(GeneralConstants.favRecipesText.rawValue)
                        Text.updatedText(
                            GeneralConstants.favRecipesSubText.rawValue,
                            color: .gray,
                            multilineTextAlignment: .center
                        )
                    }
                    Spacer()
                }
            }
            .navigationTitle(GeneralConstants.myFav.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: {
                recipesCoreDataInstance = DBManager.sharedInstance.fetchRecipesData()
                print("recipesCoreDataInstance ==>",recipesCoreDataInstance)
            })
        }
    }
}

#Preview {
    FavouritesView()
}
