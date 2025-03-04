//
//  RecipeCardView.swift
//  Reciplease
//
//  Created by Bilal Dallali on 16/01/2025.
//

import SwiftUI

struct RecipeCardView: View {
    
    let recipe: CommonRecipe
    
    var body: some View {
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
                            Text("\(Int(recipe.calories ?? 0))")
                                .foregroundStyle(Color("WhiteFont"))
                                .font(.custom("PlusJakartaSans-Semibold", size: 15))
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                            Image(systemName: "fork.knife.circle.fill")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundStyle(Color("WhiteFont"))
                        }
                        HStack(spacing: 5) {
                            Text("\(Int(recipe.totalTime ?? 0))m")
                                .foregroundStyle(Color("WhiteFont"))
                                .font(.custom("PlusJakartaSans-Semibold", size: 15))
                                .minimumScaleFactor(0.2)
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
                            Text(recipe.label)
                                .foregroundStyle(Color("WhiteFont"))
                                .font(.custom("PlusJakartaSans-Semibold", size: 24))
                                .multilineTextAlignment(.leading)
                                .minimumScaleFactor(0.5)
                            Text(recipe.ingredientLines.joined(separator: ", "))
                                .foregroundStyle(Color("WhiteFont"))
                                .font(.custom("PlusJakartaSans-Regular", size: 18))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
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

#Preview {
    RecipeCardView(recipe: Recipe(label: "LabelLabelLabelLabelLabelLabelLabelLabelLabelLabelLabelLabel", image: "", ingredientLines: ["ingredient1, ingredient2"], totalTime: 0.8, uri: "", calories: 0.8, url: ""))
}
