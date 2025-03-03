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
    
    // MARK: - Properties
    
    private var mockSession: Session!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // Configurer une session avec notre protocol mock
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        // Bloquer tout accès réel à internet
        if #available(iOS 13, *) {
            configuration.allowsExpensiveNetworkAccess = false
            configuration.allowsConstrainedNetworkAccess = false
        }
        configuration.allowsCellularAccess = false
        configuration.waitsForConnectivity = false
        
        mockSession = Session(configuration: configuration)
        
        // Réinitialiser les mocks entre chaque test
        MockURLProtocol.reset()
        
        print("🔧 Test configuré avec accès réseau bloqué")
    }
    
    override func tearDown() {
        mockSession = nil
        MockURLProtocol.reset()
        super.tearDown()
    }
    
    // MARK: - Test Helpers - Versions modifiées des fonctions originales
    
    // Version de test pour fetchRecipes qui utilise notre session mockée
    private func testFetchRecipes(ingredients: [String], completion: @escaping (Result<[Recipe], Error>) -> Void) {
        let query = ingredients.joined(separator: ",")
        let baseUrl = "https://api.edamam.com/api/recipes/v2?type=public&q=\(query)&app_id=\(appId)&app_key=\(appKey)"
        
        print("🔍 URL requête: \(baseUrl)")
        
        mockSession.request(baseUrl, headers: ["Edamam-Account-User": "Reciplease"])
            .validate()
            .responseDecodable(of: RecipeResponse.self) { response in
                switch response.result {
                case .success(let recipeResponse):
                    completion(.success(recipeResponse.hits.map { $0.recipe }))
                case .failure(let error):
                    print("❌ Error fetching recipes:", error.localizedDescription)
                    completion(.failure(error))
                }
            }
    }
    
    // Version de test pour fetchRecipeByURI qui utilise notre session mockée
    private func testFetchRecipeByURI(uri: String, completion: @escaping (Result<RecipeDetails, Error>) -> Void) {
        let uriComponents = uri.components(separatedBy: "#recipe_").last ?? uri
        
        let baseUrl = "https://api.edamam.com/api/recipes/v2/\(uriComponents)?type=public&app_id=\(appId)&app_key=\(appKey)"
        
        print("🔍 URL requête: \(baseUrl)")
        
        mockSession.request(baseUrl, headers: ["Edamam-Account-User": "Reciplease"])
            .validate()
            .responseDecodable(of: RecipeDetailsResponse.self) { response in
                switch response.result {
                case .success(let recipeResponse):
                    completion(.success(recipeResponse.recipe))
                case .failure(let error):
                    print("❌ Error fetching recipe details:", error.localizedDescription)
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Tests
    
    func testFetchRecipes_Success() {
        // Configurer le mock avec les valeurs exactes attendues
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
                }
            ]
        }
        """.data(using: .utf8)!
        
        // Configurer une réponse mockée
        MockURLProtocol.mockResponse(urlContains: "api/recipes/v2?type=public", statusCode: 200, data: mockJSON)
        
        // Expectation pour test asynchrone
        let expectation = self.expectation(description: "Fetching Recipes")
        
        // Appeler la version de test
        testFetchRecipes(ingredients: ["Salade"]) { result in
            switch result {
            case .success(let recipes):
                print("✅ Recettes récupérées: \(recipes.count)")
                if let first = recipes.first {
                    print("📋 Première recette: \(first.label), calories: \(String(describing: first.calories))")
                }
                
                // Vérifications
                XCTAssertEqual(recipes.count, 1)
                XCTAssertEqual(recipes.first?.label, "Salade Indochinoise")
                XCTAssertEqual(recipes.first?.calories, 390.12750000014796)
            case .failure(let error):
                XCTFail("Échec inattendu: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testFetchRecipeByURI_Success() {
        // ID de recette de test
        let testRecipeID = "304399cfec7404bb253e8ea039b36544"
        
        // Mock JSON avec les valeurs attendues
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
        
        // Configurer le mock
        MockURLProtocol.mockResponse(urlContains: "api/recipes/v2/\(testRecipeID)?type=public", statusCode: 200, data: mockJSON)
        
        let expectation = self.expectation(description: "Fetching Recipe by URI")
        
        // Appeler la version de test
        testFetchRecipeByURI(uri: testRecipeID) { result in
            switch result {
            case .success(let recipe):
                print("✅ Détails récupérés: \(recipe.label)")
                
                // Vérifications
                XCTAssertEqual(recipe.label, "Salade Indochinoise")
                XCTAssertEqual(recipe.calories, 390.12750000014796)
            case .failure(let error):
                XCTFail("Échec inattendu: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testFetchRecipeByURI_Failure() {
        // Configurer une erreur réseau
        let mockError = NSError(domain: "com.reciplease", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        MockURLProtocol.mockError(urlContains: "api/recipes/v2/unknown", error: mockError)

        let expectation = self.expectation(description: "Fetching Recipe by URI Failure")

        // Appeler la version de test
        testFetchRecipeByURI(uri: "unknown") { result in
            switch result {
            case .success:
                XCTFail("Succès inattendu, devrait échouer")
            case .failure(let error):
                // Vérifier l'erreur
                let nsError = error as NSError
                XCTAssertEqual(nsError.domain, "com.reciplease")
                XCTAssertEqual(nsError.code, -1)
                XCTAssertEqual(nsError.localizedDescription, "Network error")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testURIExtraction() {
        // Test de l'extraction d'ID à partir de l'URI
        let uri = "http://www.edamam.com/ontologies/edamam.owl#recipe_12345"
        let extractedId = uri.components(separatedBy: "#recipe_").last
        
        XCTAssertEqual(extractedId, "12345", "L'ID extrait devrait être '12345'")
    }
}

// MARK: - MockURLProtocol

class MockURLProtocol: URLProtocol {
    // Stockage pour les mocks
    static var mockResponses = [String: (statusCode: Int, data: Data)]()
    static var mockErrors = [String: Error]()
    
    // Réinitialiser tous les mocks
    static func reset() {
        mockResponses.removeAll()
        mockErrors.removeAll()
        print("🧹 Mocks réinitialisés")
    }
    
    // Ajouter une réponse mockée
    static func mockResponse(urlContains: String, statusCode: Int = 200, data: Data) {
        mockResponses[urlContains] = (statusCode, data)
        print("📝 Mock ajouté pour URL contenant: \(urlContains)")
    }
    
    // Ajouter une erreur mockée
    static func mockError(urlContains: String, error: Error) {
        mockErrors[urlContains] = error
        print("📝 Erreur ajoutée pour URL contenant: \(urlContains)")
    }
    
    // MARK: - Implémentation URLProtocol
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true // Intercepter toutes les requêtes
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        // Extraire l'URL
        guard let url = request.url?.absoluteString else {
            let error = NSError(domain: "MockURLProtocol", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL invalide"])
            client?.urlProtocol(self, didFailWithError: error)
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        print("🔍 Requête interceptée: \(url)")
        
        // Vérifier s'il y a une erreur configurée pour cette URL
        for (urlSubstring, error) in Self.mockErrors where url.contains(urlSubstring) {
            print("⚠️ Erreur mock trouvée pour: \(urlSubstring)")
            client?.urlProtocol(self, didFailWithError: error)
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        // Vérifier s'il y a une réponse mockée pour cette URL
        for (urlSubstring, responseTuple) in Self.mockResponses where url.contains(urlSubstring) {
            print("✅ Réponse mock trouvée pour: \(urlSubstring)")
            
            // Créer et envoyer la réponse HTTP
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: responseTuple.statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: responseTuple.data)
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        // Si aucun mock ne correspond, échec avec erreur explicite
        print("❌ AUCUN MOCK TROUVÉ pour: \(url)")
        print("   Mocks disponibles: \(Self.mockResponses.keys.joined(separator: ", "))")
        
        let error = NSError(
            domain: "MockURLProtocol",
            code: 404,
            userInfo: [
                NSLocalizedDescriptionKey: "Aucun mock configuré pour cette URL: \(url)",
                "url": url
            ]
        )
        client?.urlProtocol(self, didFailWithError: error)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // Rien à faire ici
    }
}
