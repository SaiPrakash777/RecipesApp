//
//  RecipeView.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 09/10/25.
//

import SwiftUI

// MARK: - Tab View
struct MainTabView: View {
    let networkService = NetworkClass()
    var body: some View {
        TabView {
            RecipesView(recipesVM: RecipesVM(networkService: networkService))
                .tabItem {
                    Label(GeneralConstants.recipe.rawValue, systemImage: ImageIcons.forkAndKnifeIcon.rawValue)
                }
            
            FavoritesView()
                .tabItem {
                    Label(GeneralConstants.fav.rawValue, systemImage: ImageIcons.heartIcon.rawValue)
                }
            
            ShoppingView()
                .tabItem {
                    Label(GeneralConstants.shopping.rawValue, systemImage: ImageIcons.cartIcon.rawValue)
                }
        }
        .accentColor(.green) // active tab color
    }
}
struct RecipesView<VM :RecipesVM>: View {
    @StateObject var recipesVM: VM
    @State private var searchText = ""
    @State private var selectedSortOption: SortingOptions? = nil
    @State private var selectedFilter: FilterOptions? = .all
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                //SEARCH BAR
                HStack {
                    Image(systemName: ImageIcons.magnifyingGlassIcon.rawValue)
                    TextField("Search recipes...", text: $searchText)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                //FILTER BUTTONS
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(FilterOptions.allCases, id: \.self) { filter in
                            Button {
                                selectedFilter = filter
                            } label: {
                                Text(filter.rawValue)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 14)
                                    .background(selectedFilter == filter ? Color.green.opacity(0.8) : Color(.systemGray5))
                                    .foregroundColor(selectedFilter == filter ? .white : .black)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                //LIST VIEW
                recipesContent()
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.inline)
            //NAVBARITEMS
            .navigationBarItems(trailing: navBarItem())
            .task {
                await recipesVM.fetchRecipesData()
            }
            
        }
    }
}

// MARK: - Favorites Screen
struct FavoritesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: ImageIcons.heartFillIcon.rawValue)
                    .font(.system(size: 60))
                    .foregroundColor(.pink)
                Text("Your favorite recipes will appear here!")
                    .font(.headline)
                    .padding(.top)
            }
            .navigationTitle("Favorites")
        }
    }
}

// MARK: - Shopping Screen
struct ShoppingView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: ImageIcons.cartFillIcon.rawValue)
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                Text("Your shopping list is empty.")
                    .font(.headline)
                    .padding(.top)
            }
            .navigationTitle("Shopping")
        }
    }
}

#Preview {
    MainTabView()
}
extension RecipesView {
    func getFilteredAndSortedRecipes() -> [Recipes] {
        var result = recipesVM.recipes.filter { recipe in
            let searchedText = searchText.isEmpty || (recipe.name?.localizedCaseInsensitiveContains(searchText) ?? false)
            let filteredText = selectedFilter == .all || (recipe.tags?.contains(where: { $0.lowercased() == selectedFilter?.rawValue.lowercased() }) ?? false)
            return searchedText && filteredText
        }
        
        if let option = selectedSortOption {
            switch option {
            case .name:
                result.sort { ($0.name ?? "") < ($1.name ?? "") }
            case .cookingTime:
                result.sort { ($0.cookTimeMinutes ?? 0) < ($1.cookTimeMinutes ?? 0) }
            case .rating:
                result.sort { ($0.rating ?? 0.0) > ($1.rating ?? 0.0) }
            case .difficulty:
                let difficultyOrder: [String: Int] = ["Easy": 0, "Medium": 1, "Hard": 2]
                result.sort {
                    let first = difficultyOrder[$0.difficulty ?? ""] ?? 3
                    let second = difficultyOrder[$1.difficulty ?? ""] ?? 3
                    return first < second
                }
            }
        }
        //If filtered array is empty, try fetching again
            if result.isEmpty && !recipesVM.hasRecipes {
                Task { await recipesVM.fetchRecipesData() }
            }
        return result
    }
}
extension RecipesView {
    @ViewBuilder
    func recipesContent() -> some View {
        let filteredRecipes = getFilteredAndSortedRecipes()
        
        if recipesVM.isSuccess {
            List(filteredRecipes, id: \.id) { recipe in
                recipeRows(recipe)
            }
            .listStyle(PlainListStyle())
        } else if let error = recipesVM.errorMessage {
            Spacer()
            Text(error)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        } else {
            Spacer()
            Text("Fetching recipes...")
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
    @ViewBuilder
    func recipeRows(_ recipe: Recipes) -> some View {
        HStack(alignment: .top, spacing: 12) {
            CachedImageView(
                urlString: recipe.image,
                placeholder: "photo",
                width: 60,
                height: 60,
                cornerRadius: 8
            )
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(recipe.name ?? "Unknown")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        print("added to fav")
                    }) {
                        Image(systemName: ImageIcons.heartIcon.rawValue)
                    }
                }
                
                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        Image(systemName: ImageIcons.clockIcon.rawValue)
                            .foregroundColor(.gray)
                        Text("\(recipe.cookTimeMinutes ?? 0) min")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    Text("•")
                    HStack(spacing: 3) {
                        Image(systemName: ImageIcons.forkAndKnifeIcon.rawValue)
                            .foregroundColor(.gray)
                        Text("\(recipe.servings ?? 0) servings")
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
                        Text(String(format: "%.1f", recipe.rating ?? 0.0))
                            .font(.subheadline)
                    }
                    
                    Text(recipe.cuisine ?? "")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(6)
                    
                    if let difficulty = recipe.difficulty {
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
extension RecipesView{
    func navBarItem() -> some View{
        Menu { // sort dropdown
            ForEach(SortingOptions.allCases, id: \.self) { option in
                Button(option.rawValue, action: {
                    selectedSortOption = option
                    print("Selected sort: \(option)")
                })
            }
        } label: {
            Image(systemName: ImageIcons.arrowsIcon.rawValue)
                .foregroundColor(selectedSortOption == nil ? .green : .green)
        }
    }
}
