//
//  GetRequests.swift
//  Reciplease
//
//  Created by Bilal Dallali on 21/01/2025.
//

import Foundation
import Alamofire

let appId = "2c51822c"
let appKey = ""

func fetchRecipes(ingredients: [String], completion: @escaping (Result<[Recipe], Error>) -> Void) {
    let query = ingredients.joined(separator: ",")
    let baseUrl = "https://api.edamam.com/api/recipes/v2?type=public&q=\(query)&app_id=\(appId)&app_key=\(appKey)"
    
    print("url \(baseUrl)")
    AF.request(baseUrl, headers: ["Edamam-Account-User": "Reciplease"])
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

func fetchRecipeByURI(uri: String, completion: @escaping (Result<RecipeDetails, Error>) -> Void) {
    // ✅ Extraction correcte de l'ID de la recette
    let uriComponents = uri.components(separatedBy: "#recipe_").last ?? uri
    
    // ✅ URL correcte pour récupérer une recette unique
    let baseUrl = "https://api.edamam.com/api/recipes/v2/\(uriComponents)?type=public&app_id=\(appId)&app_key=\(appKey)"

    print("🔍 URL requête : \(baseUrl)")
//    AF.request(baseUrl, headers: ["Edamam-Account-User": "Reciplease"])
//        .validate()
//        .serializingDecodable(RecipeDetailsResponse.self)
    AF.request(baseUrl, headers: ["Edamam-Account-User": "Reciplease"])
        .validate()
        .responseDecodable(of: RecipeDetailsResponse.self) { response in
            switch response.result {
            case .success(let recipeResponse):
                completion(.success(recipeResponse.recipe))

            case .failure(let error):
                print("❌ Erreur lors de la récupération de la recette :", error.localizedDescription)
                completion(.failure(error))
            }
        }
}
