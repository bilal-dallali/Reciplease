//
//  RecipeListView.swift
//  Reciplease
//
//  Created by Bilal D on 08/10/2024.
//

import SwiftUI

struct RecipeListView: View {
    
    let recipes: [CommonRecipe]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if recipes.isEmpty {
                    Text("No recipes found with those ingredients! Click on back, clear the list and add real ingredients!")
                        .foregroundStyle(Color("WhiteFont"))
                        .font(.custom("PlusJakartaSans-Bold", size: 24))
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .minimumScaleFactor(0.5)
                } else {
                    ForEach(recipes, id: \.uri) { recipe in
                        NavigationLink {
                            RecipeDetailsView(uri: recipe.uri)
                        } label: {
                            RecipeCardView(recipe: recipe)
                        }
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
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .background(Color("Background"))
    }
}

#Preview {
    RecipeListView(recipes: [])
}
