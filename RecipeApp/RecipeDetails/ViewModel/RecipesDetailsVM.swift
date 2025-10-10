//
//  RecipesDetailsVM.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 10/10/25.
//

import Foundation

class RecipesDetailsVM: RecipesVMProtocol {
    
    @Published var recipes: [Recipes] = []
    @Published var isSuccess: Bool = false
    @Published var errorMessage: String? = nil
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchRecipesDataWithUrlEndPoint(urlEndPoint: String) async {
        let (success, response, error) = await networkService.getServerRequest(
            urlPath: NetworkClass.recipeDetailsUrl + urlEndPoint,
            responseModel: RecipesDetailsDM.self
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
