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
                ForEach(recipes, id: \.uri) { recipe in
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
        }
        .background(Color("Background"))
    }
}

#Preview {
    RecipeListView(recipes: [])
}
