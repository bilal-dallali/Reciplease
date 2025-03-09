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
                NavigationStack {
                    RecipeSearchView()
                }
                .accessibilityLabel(Text("Search section"))
                .accessibilityHint(Text("search screen"))
            } else if isFavoriteSelected {
                NavigationStack {
                    FavoriteRecipeView()
                }
                .accessibilityLabel(Text("Favorite section"))
                .accessibilityHint(Text("favorite screen"))
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
                        isSearchSelected = true
                        isFavoriteSelected = false
                    } label: {
                        Text("Search")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color(isSearchSelected ? "WhiteFont" : "BorderFont"))
                            .font(.custom("Gutheng", size: 23))
                            .minimumScaleFactor(0.5)
                    }
                    .accessibilityLabel("Search Tab")
                    .accessibilityHint("Double tap to switch to the search tab")
                    .accessibilityAddTraits(.isButton)
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
                        isSearchSelected = false
                        isFavoriteSelected = true
                    } label: {
                        Text("Favorite")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color(isFavoriteSelected ? "WhiteFont" : "BorderFont"))
                            .font(.custom("Gutheng", size: 23))
                            .minimumScaleFactor(0.5)
                    }
                    .accessibilityLabel("Favorite Tab")
                    .accessibilityHint("Double tap to switch to the favorite tab")
                    .accessibilityAddTraits(.isButton)
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
