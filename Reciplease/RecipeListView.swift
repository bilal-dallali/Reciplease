//
//  RecipeListView.swift
//  Reciplease
//
//  Created by Bilal D on 08/10/2024.
//

import SwiftUI

struct RecipeListView: View {
    var body: some View {
        VStack {
            Text("RecipeListView")
        }
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background"))
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
}

#Preview {
    RecipeListView()
}
