//
//  MockApiRequest.swift
//  RecipleaseTests
//
//  Created by Bilal Dallali on 03/03/2025.
//

import Foundation
@testable import Reciplease

final class MockApiRequest: ApiGetRequestProtocol {
    func fetchRecipes(ingredients: [String], completion: @escaping (Result<[Reciplease.Recipe], any Error>) -> Void) {
        
    }
    
    func fetchRecipeByURI(uri: String, completion: @escaping (Result<Reciplease.RecipeDetails, any Error>) -> Void) {
        
    }
    
    
}

class MockApiGetRequest: ApiGetRequestProtocol {
    var mockResult: Result<[Recipe], Error>?

    func fetchRecipes(ingredients: [String], completion: @escaping (Result<[Recipe], Error>) -> Void) {
        if let result = mockResult {
            completion(result)
        }
    }

    func fetchRecipeByURI(uri: String, completion: @escaping (Result<RecipeDetails, Error>) -> Void) {
        // Implémentation non nécessaire pour ce test
    }
}
