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
            
            FavouritesView()
                .tabItem {
                    Label(GeneralConstants.fav.rawValue, systemImage: ImageIcons.heartIcon.rawValue)
                }
            
            ShoppingView()
                .tabItem {
                    Label(GeneralConstants.shopping.rawValue, systemImage: ImageIcons.cartIcon.rawValue)
                }
        }
        .accentColor(.green)
    }
}
struct RecipesView<VM :RecipesVM>: View {
    @StateObject var recipesVM: VM
    @State private var searchText = ""
    @State private var selectedSortOption: SortingOptions? = nil
    @State private var selectedFilter: FilterOptions? = .all
    @State var recipesCoreDataInstance = [RecipesEntity]()
    
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
                    .padding(.bottom,5)
                }
                //LIST VIEW
                recipesContent()
            }
            .navigationTitle(GeneralConstants.recipe.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            //NAVBARITEMS
            .navigationBarItems(trailing: navBarItem())
            .onAppear(perform: {
                recipesCoreDataInstance = DBManager.sharedInstance.fetchRecipesData()
                print("recipesCoreDataInstance ==>",recipesCoreDataInstance)
            })
            .task {
                await recipesVM.fetchRecipesData()
            }
            
        }
    }
}

#Preview {
    MainTabView()
}
extension RecipesView {
    func getFilteredAndSortedRecipes() -> [Recipes] {
        var result = recipesVM.recipes.filter { recipe in
            let searchedText = searchText.isEmpty 
            || (recipe.name?.localizedCaseInsensitiveContains(searchText) ?? false) 
            || (recipe.ingredients?.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) ?? false)
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
            case .favourite:
                result = result.filter { recipe in
                    recipesCoreDataInstance.contains { $0.recipeId == recipe.id ?? 0 }
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
            ScrollView {
                Divider()
                LazyVStack(spacing: 10) {
                    ForEach(filteredRecipes, id: \.id) { recipe in
                        NavigationLink(destination: RecipeDetailsView(recipesDetailsVM: RecipesDetailsVM(networkService: NetworkClass()), recipeName: recipe.name ?? "")) {
                            ListView(
                                name: recipe.name ?? "",
                                cookTime: recipe.cookTimeMinutes ?? 0,
                                servings: recipe.servings ?? 0,
                                rating: recipe.rating ?? 0.0,
                                cuisine: recipe.cuisine ?? "",
                                difficulty: recipe.difficulty ?? "",
                                imageURL: recipe.image ?? "",
                                isFavorite: Binding(
                                    get: { recipesCoreDataInstance.contains { $0.recipeId == recipe.id ?? 0 } },
                                    set: { _ in }
                                ),
                                    onFavTap: {
                                        if recipesCoreDataInstance.contains(where: { $0.recipeId == recipe.id ?? 0 }) {
                                            DBManager.sharedInstance.deleteRecipeRecord(recipeId: recipe.id ?? 0)
                                        } else {
                                            DBManager.sharedInstance.createRecipeRecord(record: recipe)
                                        }
                                        recipesCoreDataInstance = DBManager.sharedInstance.fetchRecipesData()
                                    }
                            )
                        }
                        .buttonStyle(.plain)
                        Divider()
                    }
                }
                .padding(.horizontal)
            }
        }else if let error = recipesVM.errorMessage {
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
