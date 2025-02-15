//
//  RecipeTabView.swift
//  Reciplease
//
//  Created by Bilal Dallali on 11/10/2024.
//

import SwiftUI

struct RecipeTabView: View {
    
    @State private var isSearchSelected: Bool = true
    @State private var isFavoriteSelected: Bool = false
    
    
    var body: some View {
        ZStack {
            if isSearchSelected {
                RecipeSearchView()
            } else if isFavoriteSelected {
                FavoriteRecipeView()
            }
            VStack(spacing: 0) {
                Spacer()
                Divider()
                    .overlay {
                        Rectangle()
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("BorderFont"))
                    }
                HStack {
                    Spacer()
                    Button {
                        print("Search")
                        isSearchSelected = true
                        isFavoriteSelected = false
                    } label: {
                        Text("Search")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color(isSearchSelected ? "WhiteFont" : "BorderFont"))
                            .font(.custom("Gutheng", size: 23))
                    }
                    Spacer()
                    Divider()
                        .overlay {
                            Rectangle()
                                .frame(height: 50)
                                .frame(width: 1)
                                .foregroundColor(Color("BorderFont"))
                        }
                    Spacer()
                    Button {
                        print("Favorite")
                        isSearchSelected = false
                        isFavoriteSelected = true
                    } label: {
                        Text("Favorite")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color(isFavoriteSelected ? "WhiteFont" : "BorderFont"))
                            .font(.custom("Gutheng", size: 23))
                    }
                    Spacer()
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color("Background"))
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    RecipeTabView()
}
