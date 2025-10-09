//
//  RecipesVM.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 09/10/25.
//

import Foundation
protocol RecipesVMProtocol: ObservableObject{
    var recipes: [Recipes] { get set }
    var isSuccess: Bool { get set }
    var errorMessage: String? { get set }
    func fetchRecipesData() async
}
class RecipesVM: RecipesVMProtocol {
    
    @Published var recipes: [Recipes] = []
    @Published var isSuccess: Bool = false
    @Published var errorMessage: String? = nil
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchRecipesData() async {
        let (success, response, error) = await networkService.getServerRequest(
            urlPath: NetworkClass.recipeUrl,
            responseModel: RecipesDM.self
        )
        DispatchQueue.main.async {
            if success, let data = response {
                self.recipes = data.recipes ?? []
                self.isSuccess = true
                self.errorMessage = nil
            } else {
                self.recipes = []
                self.isSuccess = false
                self.errorMessage = error?.localizedDescription ?? "Failed to fetch recipes."
            }
        }
    }
}




