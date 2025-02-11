//
//  RecipeData.swift
//  Reciplease
//
//  Created by Bilal Dallali on 21/01/2025.
//

import Foundation

struct RecipeResponse: Codable {
    let hits: [RecipeHit]
}

struct RecipeHit: Codable {
    let recipe: Recipe
}

struct Recipe: Codable, CommonRecipe {
    let label: String
    let image: String?
    let ingredientLines: [String]
    let totalTime: Double?
    let uri: String
    let calories: Double?
    
    // Permet d'extraire les bonnes valeurs JSON
    enum CodingKeys: String, CodingKey {
        case label, image, ingredientLines, totalTime, uri, calories
    }
}

struct RecipeDetails: Codable {
    let label: String
    let image: String?
    let ingredientLines: [String]
    let calories: Double?
    let totalTime: Double?
    let uri: String
}

protocol CommonRecipe {
    var label: String { get }
    var image: String? { get }
    var ingredientLines: [String] { get }
    var totalTime: Double? { get }
    var uri: String { get }
    var calories: Double? { get }
}

struct RecipeDetailsResponse: Codable {
    let recipe: RecipeDetails
}
