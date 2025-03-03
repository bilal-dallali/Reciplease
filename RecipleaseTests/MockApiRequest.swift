//
//  MockApiRequest.swift
//  RecipleaseTests
//
//  Created by Bilal Dallali on 03/03/2025.
//

import Foundation
@testable import Reciplease

class MockNetworkService: NetworkServiceProtocol {
    var shouldReturnError = false

    func request<T: Decodable>(_ url: String, completion: @escaping (Result<T, Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock Error"])))
            return
        }

        if url.contains("recipes/v2?") {
            let mockResponse = RecipeResponse(hits: [RecipeHit(recipe: Recipe(
                label: "Mock Recipe",
                image: "https://example.com/image.jpg",
                ingredientLines: ["Salt", "Pepper"],
                totalTime: 30,
                uri: "mock_uri",
                calories: 200,
                url: "https://example.com/recipe"
            ))])
            
            completion(.success(mockResponse as! T)) // Force cast for generic
        } else {
            let mockDetailsResponse = RecipeDetailsResponse(recipe: RecipeDetails(
                label: "Mock Recipe Details",
                image: "https://example.com/detail.jpg",
                ingredientLines: ["Flour", "Sugar"],
                calories: 500,
                totalTime: 45,
                uri: "mock_uri_details",
                url: "https://example.com/recipe_details"
            ))
            
            completion(.success(mockDetailsResponse as! T))
        }
    }
}
