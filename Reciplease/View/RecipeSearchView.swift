//
//  ContentView.swift
//  Reciplease
//
//  Created by Bilal Dallali on 26/09/2024.
//

import SwiftUI

struct RecipeSearchView: View {
    
    @State private var ingredientsText: String = ""
    @State private var ingredientsList: [String] = []
    @FocusState private var focusedTextField: Bool
    @State private var redirectRecipeList: Bool = false
    @State private var alertListEmpty: Bool = false
    
    @State private var recipes: [CommonRecipe] = []
    var apiGetManager = ApiGetRequest()
    
    var body: some View {
        VStack {
            VStack(spacing: 22) {
                VStack(spacing: 15) {
                    Text("Reciplease")
                        .foregroundStyle(Color("WhiteFont"))
                        .font(.custom("Gutheng", size: 25))
                        .accessibilityLabel("Title of the app Reciplease")
                        .accessibilityAddTraits(.isHeader)
                    VStack(spacing: 16) {
                        Text("What’s in your fridge ?")
                            .foregroundStyle(Color("DarkFont"))
                            .font(.custom("PlusJakartaSans-Medium", size: 24))
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                            .accessibilityLabel("Which ingredients do you have in your fridge ?")
                        HStack(spacing: 10) {
                            VStack(spacing: 3) {
                                TextField(text: $ingredientsText) {
                                    Text("Lemon, Cheese, Sausages...")
                                        .foregroundStyle(Color("GreyFont"))
                                        .font(.custom("PlusJakartaSans-Medium", size: 19))
                                }
                                .textInputAutocapitalization(.never)
                                .keyboardType(.default)
                                .font(.custom("PlusJakartaSans-Medium", size: 19))
                                .foregroundStyle(Color("DarkFont"))
                                .frame(height: 26)
                                .minimumScaleFactor(0.5)
                                .focused($focusedTextField)
                                .onSubmit {
                                    if !ingredientsText.isEmpty {
                                        ingredientsList.append(ingredientsText)
                                        ingredientsText = ""
                                    }
                                }
                                .submitLabel(.done)
                                .accessibilityLabel(Text("Ingredient input field"))
                                .accessibilityHint(Text("Add your ingredients and submit to add ingredient to your list"))
                                Divider()
                                    .overlay {
                                        Rectangle()
                                            .foregroundStyle(Color("GreyFont"))
                                            .frame(height: 1)
                                    }
                            }
                            Button {
                                if !ingredientsText.isEmpty {
                                    ingredientsList.append(ingredientsText)
                                    ingredientsText = ""
                                }
                            } label: {
                                Text("Add")
                                    .foregroundStyle(Color("WhiteFont"))
                                    .font(.custom("PlusJakartaSans-Medium", size: 19))
                                    .frame(width: 75, height: 40)
                                    .background(Color("GreenButton"))
                                    .cornerRadius(3)
                                    .minimumScaleFactor(0.5)
                            }
                            .accessibilityLabel(Text("Add button"))
                            .accessibilityHint(Text("Double tap to add ingredient to your list"))
                            .accessibilityAddTraits(.isButton)
                        }
                        .padding(.horizontal, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .padding(.top, 24)
                    .padding(.bottom, 19)
                    .background(Color("WhiteFont"))
                }
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Your ingredients :")
                            .foregroundStyle(Color("WhiteFont"))
                            .font(.custom("Gutheng", size: 24))
                            .minimumScaleFactor(0.4)
                            .lineLimit(1)
                            .accessibilityLabel(Text("Your ingredients title:"))
                        Spacer()
                        Button {
                            print("clear")
                            ingredientsList.removeAll()
                        } label: {
                            Text("Clear")
                                .foregroundStyle(Color("WhiteFont"))
                                .font(.custom("PlusJakartaSans-Medium", size: 19))
                                .frame(width: 75, height: 40)
                                .background(Color("GreyFont"))
                                .cornerRadius(3)
                                .minimumScaleFactor(0.5)
                        }
                        .accessibilityLabel(Text("Clear all ingredients button"))
                        .accessibilityHint(Text("Double tap to remove all ingredients from your list"))
                        .accessibilityAddTraits(.isButton)
                    }
                    ScrollView {
                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(ingredientsList, id: \.self) { ingredient in
                                HStack {
                                    Text("- \(ingredient)")
                                        .foregroundStyle(Color("WhiteFont"))
                                        .font(.custom("Gutheng", size: 24))
                                        .padding(.leading, 13)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                        .dynamicTypeSize(.xSmall ... .accessibility3)
                                        .accessibilityLabel("Your ingredient : \(ingredient)")
                                    Spacer()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .accessibilityLabel(Text("List of your ingredients"))
                }
                .padding(.horizontal, 20)
            }
            Spacer()
            Button {
                if !ingredientsList.isEmpty {
                    apiGetManager.fetchRecipes(ingredients: ingredientsList) { result in
                        switch result {
                        case .success(let fetchedRecipes):
                            print("success \(String(describing: apiGetManager.fetchRecipes))")
                            recipes = fetchedRecipes
                            redirectRecipeList = true
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                } else {
                    alertListEmpty = true
                }
            } label: {
                Text("Search for recipes")
                    .foregroundStyle(Color("WhiteFont"))
                    .font(.custom("PlusJakartaSans-Semibold", size: 23))
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(ingredientsList.isEmpty ? "GreyFont" : "GreenButton"))
                    .cornerRadius(3)
                    .padding(.horizontal, 35)
                    .minimumScaleFactor(0.3)
            }
            .disabled(ingredientsList.isEmpty)
            .padding(.bottom, 75)
            .accessibilityLabel(Text("Search for recipes"))
            .accessibilityHint(Text("Double tap to see recipes based on your ingredients list"))
            .accessibilityAddTraits(.isButton)
            //.ignoresSafeArea(edges: .bottom)
            .navigationDestination(isPresented: $redirectRecipeList) {
                RecipeListView(recipes: recipes)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 25)
        .background(Color("Background"))
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    RecipeSearchView()
}
