//
//  RecipleaseTests.swift
//  RecipleaseTests
//
//  Created by Bilal Dallali on 03/03/2025.
//

import XCTest
import Alamofire
@testable import Reciplease

final class RecipleaseTests: XCTestCase {
    private var session: Session!
    var apiGetManager = apiGetRequest()
    
    override func setUp() {
        super.setUp()
        
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolMock.self]
        
        session = Session(configuration: configuration) // ✅ Création d'une instance personnalisée
    }
    
    func testFetchRecipes_Success() {
        let mockJSON = """
        {
            "hits": [
                {
                    "recipe": {
                        "label": "Salade César",
                        "image": "https://image.url",
                        "ingredientLines": ["Laitue", "Poulet", "Croutons"],
                        "calories": 250,
                        "totalTime": 15,
                        "uri": "recipe_123",
                        "url": "https://example.com"
                    }
                }
            ]
        }
        """.data(using: .utf8)
        
        URLProtocolMock.testResponse = (mockJSON, HTTPURLResponse(url: URL(string: "https://api.edamam.com")!,
                                                                  statusCode: 200, httpVersion: nil, headerFields: nil), nil)
        
        let expectation = self.expectation(description: "Fetching Recipes")
        
        apiGetManager.fetchRecipes(ingredients: ["Salade"]) { result in
            switch result {
            case .success(let recipes):
                XCTAssertEqual(recipes.count, 20)
                XCTAssertEqual(recipes.first?.label, "Salade Indochinoise")
                XCTAssertEqual(recipes.first?.calories, 390.12750000014796)
            case .failure(let error):
                XCTFail("Erreur inattendue : \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    
    func testFetchRecipeByURI_Success() {
        let testRecipeID = "304399cfec7404bb253e8ea039b36544"
        let testURL = URL(string: "https://api.edamam.com/api/recipes/v2/\(testRecipeID)?type=public&app_id=\(appId)&app_key=\(appKey)")!

        let mockJSON = """
        {
            "recipe": {
                "label": "Pizza Margherita",
                "image": "https://image.url",
                "ingredientLines": ["Tomate", "Mozzarella", "Basilic"],
                "calories": 800,
                "totalTime": 30,
                "uri": "recipe_\(testRecipeID)",
                "url": "https://example.com"
            }
        }
        """.data(using: .utf8)
        
        URLProtocolMock.testResponse = (mockJSON, HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
        
        let expectation = self.expectation(description: "Fetching Recipe by URI")
        
        apiGetManager.fetchRecipeByURI(uri: testRecipeID) { result in
            switch result {
            case .success(let recipe):
                XCTAssertEqual(recipe.label, "Salade Indochinoise")
                XCTAssertEqual(recipe.calories, 390.12750000014796)
            case .failure(let error):
                XCTFail("Erreur inattendue : \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchRecipeByURI_Failure() {
        let mockError = NSError(domain: "com.reciplease", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error"])

        URLProtocolMock.testResponse = (nil, nil, mockError)

        let expectation = self.expectation(description: "Fetching Recipe by URI Failure")

        apiGetManager.fetchRecipeByURI(uri: "recipe_unknown") { result in
            switch result {
            case .success:
                XCTFail("L'appel API ne devrait pas réussir")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Response status code was unacceptable: 404.", "L'erreur ne correspond pas")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}

class URLProtocolMock: URLProtocol {
    static var testResponse: (data: Data?, response: URLResponse?, error: Error?)?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = URLProtocolMock.testResponse?.error {
            // Si une erreur est définie, la renvoyer directement
            client?.urlProtocol(self, didFailWithError: error)
        } else if let response = URLProtocolMock.testResponse?.response,
                  let data = URLProtocolMock.testResponse?.data {
            // Sinon, on charge les données avec la réponse
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self) // Fin de l'appel
    }
    
    override func stopLoading() {}
}
