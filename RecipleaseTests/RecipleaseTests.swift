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
        
        // Intercepter TOUTES les requêtes HTTP au niveau du système
        NetworkInterceptor.startIntercepting()
        
        // Réinitialiser les mocks entre les tests
        NetworkInterceptor.reset()
        
        print("🔧 Test configuré : interception réseau activée")
    }
    
    override func tearDown() {
        // Arrêter l'interception
        NetworkInterceptor.stopIntercepting()
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testFetchRecipes_Success() {
        // Configurer le mock avec les valeurs exactes attendues par vos assertions
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
        
        // Configurer la réponse mockée pour les URLs contenant cette chaîne
        NetworkInterceptor.mockResponse(urlContains: "v2?type=public&q=", statusCode: 200, data: mockJSON)
        
        // Expectation pour test asynchrone
        let expectation = self.expectation(description: "Fetching Recipes")
        
        // Appel DIRECT à votre fonction originale - pour la couverture de code
        fetchRecipes(ingredients: ["Salade"]) { result in
            switch result {
            case .success(let recipes):
                print("✅ Recettes récupérées: \(recipes.count)")
                
                // Vérifications avec les valeurs exactes du mock
                XCTAssertEqual(recipes.count, 20)
                XCTAssertEqual(recipes.first?.label, "Salade Indochinoise")
                XCTAssertEqual(recipes.first?.calories, 390.12750000014796)
            case .failure(let error):
                XCTFail("Échec inattendu: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        // Timeout court car pas de connexion internet réelle
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testFetchRecipeByURI_Success() {
        // ID de recette de test
        let testRecipeID = "304399cfec7404bb253e8ea039b36544"
        
        // Mock avec les valeurs exactes attendues dans vos assertions
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
        
        // Configurer le mock pour les URLs qui contiennent cet ID
        NetworkInterceptor.mockResponse(urlContains: testRecipeID, statusCode: 200, data: mockJSON)
        
        let expectation = self.expectation(description: "Fetching Recipe by URI")
        
        // Appel DIRECT à votre fonction originale - pour la couverture de code
        fetchRecipeByURI(uri: testRecipeID) { result in
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
        NetworkInterceptor.mockError(urlContains: "unknown", error: mockError)

        let expectation = self.expectation(description: "Fetching Recipe by URI Failure")

        // Appel DIRECT à votre fonction originale - pour la couverture de code
        fetchRecipeByURI(uri: "unknown") { result in
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

// MARK: - Intercepteur réseau global

/// Classe qui intercepte toutes les requêtes réseau au niveau du système
/// pour permettre de tester sans connexion internet
class NetworkInterceptor: URLProtocol {
    
    // Stockage pour les mocks
    static var mockResponses = [String: (statusCode: Int, data: Data)]()
    static var mockErrors = [String: Error]()
    static var requestLog = [URLRequest]()
    
    // Activer l'interception au niveau système
    static func startIntercepting() {
        // S'enregistrer pour TOUTES les requêtes
        URLProtocol.registerClass(NetworkInterceptor.self)
        
        // Configurer toutes les configurations par défaut
        let sessionConfigs: [URLSessionConfiguration] = [
            .default,
            .ephemeral,
            URLSessionConfiguration.af.default
        ]
        
        for config in sessionConfigs {
            // Ajouter notre intercepteur en premier dans les protocol classes
            // Correction de l'erreur: création d'un nouveau tableau au lieu d'append
            if let existingClasses = config.protocolClasses {
                config.protocolClasses = [NetworkInterceptor.self] + existingClasses
            } else {
                config.protocolClasses = [NetworkInterceptor.self]
            }
            
            // Désactiver l'accès internet réel
            config.allowsCellularAccess = false
            config.waitsForConnectivity = false
            if #available(iOS 13, *) {
                config.allowsExpensiveNetworkAccess = false
                config.allowsConstrainedNetworkAccess = false
            }
        }
        
        print("🔒 Interception réseau activée - tous les accès internet bloqués")
    }
    
    // Désactiver l'interception
    static func stopIntercepting() {
        URLProtocol.unregisterClass(NetworkInterceptor.self)
        print("🔓 Interception réseau désactivée")
    }
    
    // Réinitialiser les mocks
    static func reset() {
        mockResponses.removeAll()
        mockErrors.removeAll()
        requestLog.removeAll()
        print("🧹 Mocks et logs réinitialisés")
    }
    
    // Ajouter une réponse mockée
    static func mockResponse(urlContains: String, statusCode: Int = 200, data: Data) {
        mockResponses[urlContains] = (statusCode, data)
        print("📝 Réponse mock configurée pour URL contenant: '\(urlContains)'")
    }
    
    // Ajouter une erreur mockée
    static func mockError(urlContains: String, error: Error) {
        mockErrors[urlContains] = error
        print("📝 Erreur mock configurée pour URL contenant: '\(urlContains)'")
    }
    
    // Afficher les requêtes interceptées
    static func logRequests() {
        print("📊 Requêtes interceptées: \(requestLog.count)")
        for (index, request) in requestLog.enumerated() {
            if let url = request.url?.absoluteString {
                print("  \(index+1). \(url)")
            }
        }
    }
    
    // MARK: - Implémentation URLProtocol
    
    override class func canInit(with request: URLRequest) -> Bool {
        // Intercepter TOUTES les requêtes HTTP/HTTPS
        return request.url?.scheme == "http" || request.url?.scheme == "https"
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        // Journaliser la requête
        Self.requestLog.append(request)
        
        // Extraire l'URL
        guard let url = request.url?.absoluteString else {
            let error = NSError(domain: "NetworkInterceptor", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL invalide"])
            client?.urlProtocol(self, didFailWithError: error)
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        print("🔍 Requête interceptée: \(url)")
        
        // Vérifier erreurs mockées
        for (urlSubstring, error) in Self.mockErrors where url.contains(urlSubstring) {
            print("⚠️ Erreur mock trouvée pour: '\(urlSubstring)'")
            client?.urlProtocol(self, didFailWithError: error)
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        // Vérifier réponses mockées
        for (urlSubstring, responseTuple) in Self.mockResponses where url.contains(urlSubstring) {
            print("✅ Réponse mock trouvée pour: '\(urlSubstring)'")
            
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
        
        // Si aucun mock ne correspond, erreur explicite
        print("❌ AUCUN MOCK TROUVÉ pour: \(url)")
        print("   Mocks disponibles: \(Self.mockResponses.keys.joined(separator: ", "))")
        
        let error = NSError(
            domain: "NetworkInterceptor",
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
