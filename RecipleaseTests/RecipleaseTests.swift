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
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // Configurer le protocol mock pour intercepter les requêtes HTTP
        URLProtocolMock.reset()
        URLProtocolMock.startIntercepting()
    }
    
    override func tearDown() {
        // Nettoyer
        URLProtocolMock.stopIntercepting()
        URLProtocolMock.reset()
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testFetchRecipes_Success() {
        // Configurer le mock JSON pour la réponse avec des données qui correspondent à vos assertions
        let mockJSON = """
        {
            "hits": [
                {
                    "recipe": {
                        "label": "Salade Indochinoise",
                        "image": "https://image.url",
                        "ingredientLines": ["Laitue", "Poulet", "Croutons"],
                        "calories": 390.12750000014796,
                        "totalTime": 15,
                        "uri": "http://www.edamam.com/ontologies/edamam.owl#recipe_123",
                        "url": "https://example.com"
                    }
                },
                {
                    "recipe": {
                        "label": "Salade 2",
                        "image": "https://image2.url",
                        "ingredientLines": ["Ingrédient 1", "Ingrédient 2"],
                        "calories": 200,
                        "totalTime": 10,
                        "uri": "http://www.edamam.com/ontologies/edamam.owl#recipe_456",
                        "url": "https://example2.com"
                    }
                }
            ]
        }
        """.data(using: .utf8)!
        
        // Configurer la réponse mockée avec des logs pour aider au débogage
        URLProtocolMock.mockResponse(urlContains: "api.edamam.com/api/recipes/v2", statusCode: 200, data: mockJSON)
        
        print("🔍 Test fetchRecipes - Mock configuré avec \(mockJSON.count) octets de données JSON")
        
        // Expectation pour le test asynchrone
        let expectation = self.expectation(description: "Fetching Recipes")
        
        // Appeler directement votre fonction - ça utilisera le protocole mock configuré
        fetchRecipes(ingredients: ["Salade"]) { result in
            switch result {
            case .success(let recipes):
                print("✅ Test fetchRecipes - Succès avec \(recipes.count) recettes")
                if let firstRecipe = recipes.first {
                    print("📝 Première recette: \(firstRecipe.label), calories: \(String(describing: firstRecipe.calories))")
                }
                
                // Assertions avec exactement les mêmes valeurs que dans le JSON mock
                XCTAssertGreaterThanOrEqual(recipes.count, 1, "Devrait avoir au moins 1 recette")
                XCTAssertEqual(recipes.first?.label, "Salade Indochinoise")
                XCTAssertEqual(recipes.first?.calories, 390.12750000014796)
            case .failure(let error):
                print("❌ Test fetchRecipes - Échec avec erreur: \(error.localizedDescription)")
                XCTFail("Erreur inattendue : \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchRecipeByURI_Success() {
        // ID de recette de test
        let testRecipeID = "304399cfec7404bb253e8ea039b36544"
        
        // JSON mock pour une recette spécifique - avec des données qui correspondent à vos assertions
        let mockJSON = """
        {
            "recipe": {
                "label": "Salade Indochinoise",
                "image": "https://image.url",
                "ingredientLines": ["Ingrédient 1", "Ingrédient 2", "Ingrédient 3"],
                "calories": 390.12750000014796,
                "totalTime": 30,
                "uri": "http://www.edamam.com/ontologies/edamam.owl#recipe_\(testRecipeID)",
                "url": "https://example.com"
            }
        }
        """.data(using: .utf8)!
        
        // Configurer une réponse mockée pour cette URI spécifique
        URLProtocolMock.mockResponse(urlContains: "api/recipes/v2/\(testRecipeID)", statusCode: 200, data: mockJSON)
        
        print("🔍 Test fetchRecipeByURI - Mock configuré avec \(mockJSON.count) octets de données JSON")
        
        let expectation = self.expectation(description: "Fetching Recipe by URI")
        
        // Appeler directement votre fonction
        fetchRecipeByURI(uri: testRecipeID) { result in
            switch result {
            case .success(let recipe):
                print("✅ Test fetchRecipeByURI - Succès avec recette: \(recipe.label), calories: \(String(describing: recipe.calories))")
                
                // Assertions avec exactement les mêmes valeurs que dans le JSON mock
                XCTAssertEqual(recipe.label, "Salade Indochinoise")
                XCTAssertEqual(recipe.calories, 390.12750000014796)
            case .failure(let error):
                print("❌ Test fetchRecipeByURI - Échec avec erreur: \(error.localizedDescription)")
                XCTFail("Erreur inattendue : \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchRecipeByURI_Failure() {
        // Configurer une erreur à renvoyer
        let mockError = NSError(domain: "com.reciplease", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        URLProtocolMock.mockError(urlContains: "api/recipes/v2/unknown", error: mockError)

        print("🔍 Test fetchRecipeByURI_Failure - Mock erreur configuré")

        let expectation = self.expectation(description: "Fetching Recipe by URI Failure")

        // Appeler directement votre fonction
        fetchRecipeByURI(uri: "unknown") { result in
            switch result {
            case .success:
                print("❌ Test fetchRecipeByURI_Failure - Succès inattendu !")
                XCTFail("L'appel API ne devrait pas réussir")
            case .failure(let error):
                print("✅ Test fetchRecipeByURI_Failure - Échec attendu avec erreur: \(error.localizedDescription)")
                // Vérifier que l'erreur correspond à celle que nous avons configurée
                let nsError = error as NSError
                XCTAssertEqual(nsError.domain, "com.reciplease")
                XCTAssertEqual(nsError.code, -1)
                XCTAssertEqual(nsError.localizedDescription, "Network error")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}

// MARK: - URLProtocolMock avec contrôle plus précis

class URLProtocolMock: URLProtocol {
    // Stockage pour les réponses et erreurs mockées
    static var mockResponses = [String: (statusCode: Int, data: Data)]()
    static var mockErrors = [String: Error]()
    
    // Pour activer/désactiver l'interception
    static func startIntercepting() {
        URLProtocol.registerClass(URLProtocolMock.self)
        URLSessionConfiguration.default.protocolClasses = [URLProtocolMock.self] + (URLSessionConfiguration.default.protocolClasses ?? [])
        URLSessionConfiguration.af.default.protocolClasses = [URLProtocolMock.self] + (URLSessionConfiguration.af.default.protocolClasses ?? [])
        print("🔄 URLProtocolMock: Interception activée")
    }
    
    static func stopIntercepting() {
        URLProtocol.unregisterClass(URLProtocolMock.self)
        print("🔄 URLProtocolMock: Interception désactivée")
    }
    
    // Réinitialiser tous les mocks
    static func reset() {
        mockResponses.removeAll()
        mockErrors.removeAll()
        print("🧹 URLProtocolMock: Mocks réinitialisés")
    }
    
    // Ajouter une réponse mockée pour une URL (correspondance partielle)
    static func mockResponse(urlContains: String, statusCode: Int = 200, data: Data) {
        mockResponses[urlContains] = (statusCode, data)
        print("➕ URLProtocolMock: Ajout d'une réponse mock pour URLs contenant '\(urlContains)'")
    }
    
    // Ajouter une erreur mockée pour une URL (correspondance partielle)
    static func mockError(urlContains: String, error: Error) {
        mockErrors[urlContains] = error
        print("➕ URLProtocolMock: Ajout d'une erreur mock pour URLs contenant '\(urlContains)'")
    }
    
    // MARK: - Implémentation requise de URLProtocol
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        // Vérifier que la requête a une URL
        guard let url = request.url?.absoluteString else {
            fatalError("URLRequest URL is nil")
        }
        
        print("🔍 URLProtocolMock: Interception de la requête pour \(url)")
        
        // Chercher une erreur mockée qui correspond à l'URL
        for (urlSubstring, error) in URLProtocolMock.mockErrors where url.contains(urlSubstring) {
            print("✅ URLProtocolMock: Erreur mock trouvée pour \(urlSubstring)")
            client?.urlProtocol(self, didFailWithError: error)
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        // Chercher une réponse mockée qui correspond à l'URL
        for (urlSubstring, responseTuple) in URLProtocolMock.mockResponses where url.contains(urlSubstring) {
            print("✅ URLProtocolMock: Réponse mock trouvée pour \(urlSubstring)")
            
            // Créer une réponse HTTP
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: responseTuple.statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            
            // Envoyer la réponse mockée
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: responseTuple.data)
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        print("⚠️ URLProtocolMock: Aucun mock trouvé pour \(url)")
        
        // Si aucune mock ne correspond, retourner une erreur 404
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 404,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        
        let errorData = Data("{\"error\":\"No mock found for URL\"}".utf8)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: errorData)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
