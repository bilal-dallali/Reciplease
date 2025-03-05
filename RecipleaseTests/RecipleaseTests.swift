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

import XCTest

class ApiGetRequestTests: XCTestCase {
    var apiService: ApiGetRequest!
    //var mockService: MockNetworkService!

    override func setUp() {
        super.setUp()
        //mockService = MockNetworkService()
        //apiService = ApiGetRequest(networkService: mockService)
    }

    override func tearDown() {
        apiService = nil
        //mockService = nil
        super.tearDown()
    }
    
    // Tests fetch recipes success
    func testFetchRecipes_ShouldReturnMockData() {
        if let path = Bundle(for: type(of: self)).url(forResource: "mockDataRequest", withExtension: "json") {
            print("📂 Fichier mockDataRequest trouvé à : \(path)")
        } else {
            print("⚠️ Fichier mockDataRequest introuvable ! Vérifie qu'il est bien inclus dans le bundle de test.")
        }
        //let originalURL = URL(string: "https://www.example.com/api/authentication?oauth_timestamp=151817037")!
        let originalURL = URL(string: "https://api.edamam.com/api/recipes/v2?type=public&q=tomato&app_id=\(appId)&app_key=\(appKey)")!
        
        let mock = Mock(url: originalURL, ignoreQuery: true, contentType: .json, statusCode: 200, data: [
            .get : try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "mockDataRequest", withExtension: "json")!) // Data containing the JSON response
        ])
        mock.register()
        //print("mock \(mock)")
        
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        let sessionManager = Alamofire.Session(configuration: configuration)
        let service = NetworkService(sessionManager: sessionManager)
        let expectation = self.expectation(description: "Fetch Recipes")
        let apiServiceTwo = ApiGetRequest(networkService: service)
        
        apiServiceTwo.fetchRecipes(ingredients: ["tomato", "cheese"]) { result in
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
        let mockURL = URL(string: "https://api.edamam.com/api/recipes/v2?type=public&q=tomato&app_id=\(appId)&app_key=\(appKey)")!

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
                XCTFail("Expected failure but got success")
            case .failure:
                XCTAssert(true)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
//    func testFetchRecipes_ShouldReturnError() {
//        mockService.shouldReturnError = true
//        let expectation = self.expectation(description: "Fetch Recipes Error")
//
//        apiService.fetchRecipes(ingredients: ["tomato", "cheese"]) { result in
//            switch result {
//            case .success:
//                XCTFail("Expected failure but got success")
//            case .failure(let error):
//                XCTAssertEqual(error.localizedDescription, "Mock Error")
//            }
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 1, handler: nil)
//    }
    
    // Tests fetch recipe
    func testFetchRecipeByURI_ShouldReturnMockData() {
        let mockURL = URL(string: "https://api.edamam.com/api/recipes/v2/mock_uri_details?type=public&app_id=\(appId)&app_key=\(appKey)")!
        
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

        apiServiceTwo.fetchRecipeByURI(uri: "mock_uri_details") { result in
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
        let mockURL = URL(string: "https://api.edamam.com/api/recipes/v2/recipe_123?type=public&app_id=\(appId)&app_key=\(appKey)")!

        let mock = Mock(url: mockURL, ignoreQuery: true, contentType: .json, statusCode: 500, data: [.get : Data()])
        mock.register()

        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        let sessionManager = Alamofire.Session(configuration: configuration)
        let service = NetworkService(sessionManager: sessionManager)
        let expectation = self.expectation(description: "Fetch Recipe Details Error")
        let apiService = ApiGetRequest(networkService: service)

        apiService.fetchRecipeByURI(uri: "recipe_123") { result in
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
//    func testFetchRecipeByURI_ShouldReturnError() {
//        mockService.shouldReturnError = true
//        let expectation = self.expectation(description: "Fetch Recipe Details Error")
//        
//        apiService.fetchRecipeByURI(uri: "recipe_123") { result in
//            switch result {
//            case .success:
//                XCTFail("Expected failure but got success")
//            case .failure(let error):
//                XCTAssertEqual(error.localizedDescription, "Mock Error")
//            }
//            expectation.fulfill()
//        }
//        
//        waitForExpectations(timeout: 1, handler: nil)
//    }
}
