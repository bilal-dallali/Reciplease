//
//  RecipleaseTests.swift
//  RecipleaseTests
//
//  Created by Bilal Dallali on 18/02/2025.
//

import XCTest
import Alamofire
@testable import Reciplease

final class RecipleaseTests: XCTestCase {
    private var session: Session!
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
        
        fetchRecipes(ingredients: ["Salade"]) { result in
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
        if let response = URLProtocolMock.testResponse?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data = URLProtocolMock.testResponse?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        if let error = URLProtocolMock.testResponse?.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {}
}
