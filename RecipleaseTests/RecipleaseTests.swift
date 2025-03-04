//
//  RecipleaseTests.swift
//  RecipleaseTests
//
//  Created by Bilal Dallali on 03/03/2025.
//

import XCTest
import Alamofire
@testable import Reciplease

import XCTest

class ApiGetRequestTests: XCTestCase {
    var apiService: ApiGetRequest!
    var mockService: MockNetworkService!

    override func setUp() {
        super.setUp()
        mockService = MockNetworkService()
        apiService = ApiGetRequest(networkService: mockService)
    }

    override func tearDown() {
        apiService = nil
        mockService = nil
        super.tearDown()
    }
    
    // Tests fetch recipes success
    func testFetchRecipes_ShouldReturnMockData() {
        let expectation = self.expectation(description: "Fetch Recipes")
        
        apiService.fetchRecipes(ingredients: ["tomato", "cheese"]) { result in
            switch result {
            case .success(let recipes):
                XCTAssertEqual(recipes.count, 1)
                XCTAssertEqual(recipes.first?.label, "Mock Recipe")
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test fetch recipes return error
    func testFetchRecipes_ShouldReturnError() {
        mockService.shouldReturnError = true
        let expectation = self.expectation(description: "Fetch Recipes Error")

        apiService.fetchRecipes(ingredients: ["tomato", "cheese"]) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Mock Error")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Tests fetch recipe
    func testFetchRecipeByURI_ShouldReturnMockData() {
        let expectation = self.expectation(description: "Fetch Recipe Details")
        
        apiService.fetchRecipeByURI(uri: "recipe_123") { result in
            switch result {
            case .success(let recipe):
                XCTAssertEqual(recipe.label, "Mock Recipe Details")
                XCTAssertEqual(recipe.ingredientLines.count, 2)
                XCTAssertEqual(recipe.url, "https://example.com/recipe_details")
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test fetch recipe error
    func testFetchRecipeByURI_ShouldReturnError() {
        mockService.shouldReturnError = true
        let expectation = self.expectation(description: "Fetch Recipe Details Error")
        
        apiService.fetchRecipeByURI(uri: "recipe_123") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Mock Error")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
