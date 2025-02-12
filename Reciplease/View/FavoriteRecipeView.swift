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
        VStack {
            List(recipePersistents) { recipe in
                Text(recipe.uri ?? "unknown")
                Text("\(String(describing: recipe.id))")
                Text("\(recipe.calories)")
                Text(recipe.image ?? "unknown")
                Text(recipe.label ?? "unknown")
                Text("\(recipe.totalTime)")
            }
        }
    }
}

#Preview {
    FavoriteRecipeView()
}
