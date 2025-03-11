//
//  RecipleaseTests.swift
//  RecipleaseTests
//
//  Created by Bilal Dallali on 03/03/2025.
//

import XCTest
import Alamofire
import Mocker
@testable import Reciplease

class ApiGetRequestTests: XCTestCase {
    var apiService: ApiGetRequest!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        apiService = nil
        super.tearDown()
    }
    
    // Tests fetch recipes success
    func testFetchRecipes_ShouldReturnMockData() {
        // Define the API URL with authentication returns mocked data
        let originalURL = URL(string: "https://api.edamam.com/api/recipes/v2?type=public&q=tomato&app_id=\(appId)&app_key=\(appKey)")!
        
        // Create a mock response with a JSON file
        let mock = Mock(url: originalURL, ignoreQuery: true, contentType: .json, statusCode: 200, data: [
            .get : try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "mockRecipes", withExtension: "json")!) // Data containing the JSON response
        ])
        // Register the mock so that requests use the fake response
        mock.register()
        
        // Configure a mocked Alamofire session
        let configuration = URLSessionConfiguration.af.default
        //Mocking request using Mocker
        configuration.protocolClasses = [MockingURLProtocol.self]
        let sessionManager = Alamofire.Session(configuration: configuration)
        let service = NetworkService(sessionManager: sessionManager)
        // Create an expectation
        let expectation = self.expectation(description: "Fetch Recipes")
        let apiServiceTwo = ApiGetRequest(networkService: service)
        
        // Perform the api mock request
        apiServiceTwo.fetchRecipes(ingredients: ["chocolate"]) { result in
            switch result {
            case .success(let recipes):
                // Verify that 20 recipes are returned
                XCTAssertEqual(recipes.count, 20)
                // Check if the first recipe has the correct labelk
                XCTAssertEqual(recipes.first?.label, "Serious Chocolate: Easy Chocolate Pie Crust Recipe")
            case .failure:
                XCTFail("Expected success but got failure")
            }
            
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test fetch recipes return error
    func testFetchRecipes_ShouldReturnError() {
        let mockURL = URL(string: "https://api.edamam.com/api/recipes/v2?type=public&q=tomato&app_id=\(appId)&app_key=\(appKey)")!

        // Simulate an API failure with HTTP status code 500
        let mock = Mock(url: mockURL, ignoreQuery: true, contentType: .json, statusCode: 500, data: [.get : Data()])
        mock.register()

        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        let sessionManager = Alamofire.Session(configuration: configuration)
        let service = NetworkService(sessionManager: sessionManager)
        let expectation = self.expectation(description: "Fetch Recipes Error")
        let apiService = ApiGetRequest(networkService: service)

        apiService.fetchRecipes(ingredients: ["tomato", "cheese"]) { result in
            switch result {
            case .success:
                // The test fails if there is no error
                XCTFail("Expected failure but got success")
            case .failure:
                // The test pass if an error is returned
                XCTAssert(true)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Tests fetch recipe
    func testFetchRecipeByURI_ShouldReturnMockData() {
        let mockURL = URL(string: "https://api.edamam.com/api/recipes/v2/764d6feaf541a194d82d0add2dc877f5?type=public&app_id=\(appId)&app_key=\(appKey)")!
        
        let mock = Mock(url: mockURL, ignoreQuery: true, contentType: .json, statusCode: 200, data: [
            .get : try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "mockRecipeDetails", withExtension: "json")!)
        ])
        mock.register()
        
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        let sessionManager = Alamofire.Session(configuration: configuration)
        let service = NetworkService(sessionManager: sessionManager)
        let expectation = self.expectation(description: "Fetch Recipe Details")
        let apiServiceTwo = ApiGetRequest(networkService: service)
        
        apiServiceTwo.fetchRecipeByURI(uri: "764d6feaf541a194d82d0add2dc877f5") { result in
            switch result {
            case .success(let recipe):
                XCTAssertEqual(recipe.label, "Best Chocolate Pudding")
                XCTAssertEqual(recipe.ingredientLines.count, 6)
                XCTAssertEqual(recipe.url, "http://smittenkitchen.com/2008/02/best-chocolate-pudding/")
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test fetch recipe error
    func testFetchRecipeByURI_ShouldReturnError() {
        let mockURL = URL(string: "https://api.edamam.com/api/recipes/v2/recipe_123?type=public&app_id=\(appId)&app_key=\(appKey)")!

        let mock = Mock(url: mockURL, ignoreQuery: true, contentType: .json, statusCode: 500, data: [.get : Data()])
        mock.register()

        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        let sessionManager = Alamofire.Session(configuration: configuration)
        let service = NetworkService(sessionManager: sessionManager)
        let expectation = self.expectation(description: "Fetch Recipe Details Error")
        let apiService = ApiGetRequest(networkService: service)

        apiService.fetchRecipeByURI(uri: "http://www.edamam.com/ontologies/edamam.owl#recipe_764d6feaf541a194d82d0add2dc877f5") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure:
                XCTAssert(true)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}
