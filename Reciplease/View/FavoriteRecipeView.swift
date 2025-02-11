//
//  FavoriteRecipeView.swift
//  Reciplease
//
//  Created by Bilal D on 11/10/2024.
//

import SwiftUI

struct FavoriteRecipeView: View {
    
    @FetchRequest(sortDescriptors: []) var recipePersistents: FetchedResults<RecipePersistent>
    
    var body: some View {
        VStack {
            List(recipePersistents) { recipe in
                Text(recipe.uri ?? "unknwon")
            }
        }
    }
}

#Preview {
    FavoriteRecipeView()
}
