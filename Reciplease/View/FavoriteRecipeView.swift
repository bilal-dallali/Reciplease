//
//  FavoriteRecipeView.swift
//  Reciplease
//
//  Created by Bilal D on 11/10/2024.
//

import SwiftUI

struct FavoriteRecipeView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var recipePersistents: FetchedResults<RecipePersistent>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
//                List(recipePersistents) { recipe in
//                    Text(recipe.uri ?? "unknown")
//                    Text("\(String(describing: recipe.id))")
//                    Text("\(recipe.calories)")
//                    Text(recipe.image ?? "unknown")
//                    Text(recipe.label ?? "unknown")
//                    Text("\(recipe.totalTime)")
//                    ForEach(recipe.ingredientsList) { ingredient in
//                        Text("- \(ingredient)")
//                    }
//                }
                ForEach(recipePersistents, id: \.id) { recipe in
                    Text(recipe.uri ?? "unknown")
                    Text("\(String(describing: recipe.id))")
                    Text("\(recipe.calories)")
                    Text(recipe.image ?? "unknown")
                    Text(recipe.label ?? "unknown")
                    Text("\(recipe.totalTime)")
                    if let ingredientsArray = recipe.ingredients as? [String] {
                        ForEach(ingredientsArray, id: \.self) { ingredient in
                            Text("- \(ingredient)")
                        }
                    } else {
                        Text("Aucun ingrédient disponible.")
                    }
                }
            }
        }
    }
}

#Preview {
    FavoriteRecipeView()
}
