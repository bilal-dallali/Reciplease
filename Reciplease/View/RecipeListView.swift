//
//  RecipeListView.swift
//  Reciplease
//
//  Created by Bilal D on 08/10/2024.
//

import SwiftUI

struct RecipeListView: View {
    
    @State private var recipes: [CommonRecipe] = []
    @Binding var ingredientsList: [String]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(recipes, id: \.label) { recipe in
                    NavigationLink {
                        RecipeDetailsView(uri: recipe.uri)
                    } label: {
                        RecipeCardView(recipe: recipe)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButtonView()
                }
                ToolbarItem(placement: .principal) {
                    Text("Reciplease")
                        .foregroundStyle(Color("WhiteFont"))
                        .font(.custom("Gutheng", size: 25))
                }
            }
            .onAppear {
                fetchRecipes(ingredients: ingredientsList) { result in
                    switch result {
                    case .success(let fetchedRecipes):
                        print("success \(String(describing: fetchRecipes))")
                        recipes = fetchedRecipes
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
        .background(Color("Background"))
    }
}

#Preview {
    RecipeListView(ingredientsList: .constant([]))
}
