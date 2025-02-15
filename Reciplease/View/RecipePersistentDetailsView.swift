//
//  RecipePersistentDetailsView.swift
//  Reciplease
//
//  Created by Bilal Dallali on 15/02/2025.
//

import SwiftUI
import CoreData

struct RecipePersistentDetailsView: View {
    
    let recipe: RecipePersistent
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AsyncImage(url: URL(string: recipe.image ?? "")) { image in
                    image
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                } placeholder: {
                    Image("recipe-image")
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                }
                Text(recipe.label ?? "NO recipe")
                Text("Ingrédients")
                if let ingredientsArray = recipe.ingredients as? [String] {
                    ForEach(ingredientsArray, id: \.self) { ingredient in
                        Text("- \(ingredient)")
                    }
                } else {
                    Text("Aucun ingrédients")
                }
            }
        }
        .background(Color("Background"))
    }
}

#Preview {
    RecipePersistentDetailsView(recipe: .init())
}
