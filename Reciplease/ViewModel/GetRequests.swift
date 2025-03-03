//
//  GetRequests.swift
//  Reciplease
//
//  Created by Bilal Dallali on 21/01/2025.
//

import Foundation

let appId = "2c51822c"
let appKey = "7bd59a6ed43b0e0e0cd755c8cad73be3"

protocol ApiGetRequestProtocol {
    func fetchRecipes(ingredients: [String], completion: @escaping (Result<[Recipe], Error>) -> Void)
    func fetchRecipeByURI(uri: String, completion: @escaping (Result<RecipeDetails, Error>) -> Void)
}

class ApiGetRequest: ObservableObject, ApiGetRequestProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchRecipes(ingredients: [String], completion: @escaping (Result<[Recipe], Error>) -> Void) {
        let query = ingredients.joined(separator: ",")
        let url = "https://api.edamam.com/api/recipes/v2?type=public&q=\(query)&app_id=\(appId)&app_key=\(appKey)"
        
        print("🔍 URL Request: \(url)")
        
        networkService.request(url) { (result: Result<RecipeResponse, Error>) in
            switch result {
            case .success(let recipeResponse):
                completion(.success(recipeResponse.hits.map { $0.recipe }))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchRecipeByURI(uri: String, completion: @escaping (Result<RecipeDetails, Error>) -> Void) {
        let uriComponents = uri.components(separatedBy: "#recipe_").last ?? uri
        let url = "https://api.edamam.com/api/recipes/v2/\(uriComponents)?type=public&app_id=\(appId)&app_key=\(appKey)"

        print("🔍 URL Request: \(url)")

        networkService.request(url) { (result: Result<RecipeDetailsResponse, Error>) in
            switch result {
            case .success(let recipeResponse):
                completion(.success(recipeResponse.recipe))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
