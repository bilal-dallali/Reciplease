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
            VStack(spacing: 10) {
                Text("Reciplease")
                    .foregroundStyle(Color("WhiteFont"))
                    .font(.custom("Gutheng", size: 25))
                    .minimumScaleFactor(0.5)
                if recipePersistents.isEmpty {
                    Text("You have no favorite recipes yet, add some by clicking on search, then add ingredients to your list, then select your recipe and click on the favorite icon")
                        .foregroundStyle(Color("WhiteFont"))
                        .font(.custom("PlusJakartaSans-Bold", size: 24))
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .minimumScaleFactor(0.5)
                        .lineLimit(8)
                } else {
                    VStack(spacing: 0) {
                        ForEach(recipePersistents, id: \.id) { recipe in
                            NavigationLink {
                                RecipePersistentDetailsView(recipe: recipe)
                            } label: {
                                GeometryReader { geometry in
                                    ZStack(alignment: .bottomLeading) {
                                        AsyncImage(url: URL(string: recipe.image ?? "")) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Image("recipe-image")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        }
                                        .frame(height: geometry.size.height)
                                        .clipped()
                                        VStack(alignment: .trailing) {
                                            VStack(spacing: 5) {
                                                HStack(spacing: 5) {
                                                    Text("\(Int(recipe.calories))")
                                                        .foregroundStyle(Color("WhiteFont"))
                                                        .font(.custom("PlusJakartaSans-Semibold", size: 15))
                                                        .minimumScaleFactor(0.5)
                                                        .lineLimit(1)
                                                    Image(systemName: "fork.knife.circle.fill")
                                                        .resizable()
                                                        .frame(width: 14, height: 14)
                                                        .foregroundStyle(Color("WhiteFont"))
                                                }
                                                HStack(spacing: 5) {
                                                    Text("\(Int(recipe.totalTime))m")
                                                        .foregroundStyle(Color("WhiteFont"))
                                                        .font(.custom("PlusJakartaSans-Semibold", size: 15))
                                                        .minimumScaleFactor(0.5)
                                                        .lineLimit(1)
                                                    Image(systemName: "stopwatch")
                                                        .resizable()
                                                        .frame(width: 14, height: 14)
                                                        .foregroundStyle(Color("WhiteFont"))
                                                }
                                            }
                                            .frame(width: 70, height: 51)
                                            .background(Color("Background"))
                                            .clipShape(RoundedRectangle(cornerRadius: 3))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 3)
                                                    .strokeBorder(Color("WhiteFont"), lineWidth: 1)
                                            }
                                            .padding(.top, 10)
                                            .padding(.trailing, 15)
                                            Spacer()
                                            LinearGradient(gradient: Gradient(colors: [
                                                Color(red: 0, green: 0, blue: 0, opacity: 1),
                                                Color(red: 0.4, green: 0.4, blue: 0.4, opacity: 0)
                                            ]), startPoint: .bottom, endPoint: .top)
                                            .frame(height: 60)
                                            .overlay(alignment: .leading) {
                                                VStack(alignment: .leading, spacing: 0) {
                                                    Text(recipe.label ?? "unknown")
                                                        .foregroundStyle(Color("WhiteFont"))
                                                        .font(.custom("PlusJakartaSans-Semibold", size: 24))
                                                        .minimumScaleFactor(0.5)
                                                    if let ingredientsArray = recipe.ingredients as? [String] {
                                                        Text(ingredientsArray.joined(separator: ", "))
                                                            .foregroundStyle(Color("WhiteFont"))
                                                            .font(.custom("PlusJakartaSans-Regular", size: 18))
                                                            .multilineTextAlignment(.leading)
                                                            .minimumScaleFactor(0.5)
                                                            .lineLimit(1)
                                                    } else {
                                                        Text("Aucun ingrédient disponible.")
                                                    }
                                                }
                                                .padding(.leading, 12)
                                                .padding(.bottom, 9)
                                            }
                                        }
                                    }
                                }
                                .frame(height: 133)
                            }
                        }
                    }
                }
                
            }
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .background(Color("Background"))
    }
}

#Preview {
    FavoriteRecipeView()
}
