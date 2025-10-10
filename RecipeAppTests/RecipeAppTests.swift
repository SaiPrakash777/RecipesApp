//
//  RecipeAppTests.swift
//  RecipeAppTests
//
//  Created by SaiPrakash Cheera on 10/10/25.
//

import XCTest
@testable import RecipeApp

final class RecipesVMTests: XCTestCase {
    
    func testFetchRecipesSuccess() async {
        let mockService = MockNetworkService()
        mockService.mockRecipes = [
            Recipes(
                id: 1,
                name: "Pasta",
                ingredients: ["Cheese", "Tomato"],
                instructions: ["Boil pasta", "Add sauce"],
                prepTimeMinutes: 10,
                cookTimeMinutes: 20,
                servings: 2,
                difficulty: "Easy",
                cuisine: "Italian",
                caloriesPerServing: 200,
                tags: ["Dinner"],
                userId: 1,
                image: "https://example.com/pasta.jpg",
                rating: 4.5,
                reviewCount: 20,
                mealType: ["Dinner"]
            ),
            Recipes(
                id: 1,
                name: "Pasta",
                ingredients: ["Cheese", "Tomato"],
                instructions: ["Boil pasta", "Add sauce"],
                prepTimeMinutes: 10,
                cookTimeMinutes: 20,
                servings: 2,
                difficulty: "Easy",
                cuisine: "Italian",
                caloriesPerServing: 200,
                tags: ["Dinner"],
                userId: 1,
                image: "https://example.com/pasta.jpg",
                rating: 4.5,
                reviewCount: 20,
                mealType: ["Dinner"]
            )
        ]
        
        let vm = RecipesVM(networkService: mockService)
        let expectation = XCTestExpectation(description: "Wait for recipes update")
        
        let cancellable = vm.$recipes.sink { recipes in
            if recipes.count == 2 {
                expectation.fulfill()
            }
        }
        await vm.fetchRecipesData()
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(vm.recipes.count, 2)
        XCTAssertTrue(vm.isSuccess)
        XCTAssertNil(vm.errorMessage)
        cancellable.cancel()
    }
    
    func testFetchRecipesFailure() async {
        let mockService = MockNetworkService()
        mockService.shouldReturnError = true
        
        let vm = RecipesVM(networkService: mockService)
        let expectation = XCTestExpectation(description: "Wait for failure update")
        
        let cancellable = vm.$errorMessage.sink { error in
            if error != nil {
                expectation.fulfill()
            }
        }
        await vm.fetchRecipesData()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(vm.isSuccess)
        XCTAssertTrue(vm.recipes.isEmpty)
        XCTAssertNotNil(vm.errorMessage)
        cancellable.cancel()
    }
}


final class MockNetworkService: NetworkServiceProtocol {
    var shouldReturnError = false
    var mockRecipes: [Recipes] = []
    func getServerRequest<T>(urlPath: String, responseModel: T.Type) async -> (Bool, T?, Error?) where T: Decodable {
        
        if shouldReturnError {
            return (false, nil, NetworkErrors.decodingFailed)
        }
        if responseModel == RecipesDM.self {
            let response = RecipesDM(
                recipes: mockRecipes,
                total: mockRecipes.count,
                skip: 0,
                limit: mockRecipes.count
            )
            return (true, response as? T, nil)
        }
        return (false, nil, NetworkErrors.decodingFailed)
    }
}


