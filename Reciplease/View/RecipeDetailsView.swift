//
//  RecipeDetailsView.swift
//  Reciplease
//
//  Created by Bilal Dallali on 04/02/2025.
//

import SwiftUI

struct RecipeDetailsView: View {
    
    let uri: String
    @State private var recipesDetails: RecipeDetails
    
    init(uri: String) {
        self.uri = uri
        // Initialisation avec des valeurs par défaut
        _recipesDetails = State(initialValue: RecipeDetails(label: "Chargement...", image: "", ingredientLines: [], calories: 0.0, totalTime: 0.0, uri: ""))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                
                AsyncImage(url: URL(string: recipesDetails.image ?? "")) { image in
                    image
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                } placeholder: {
                    Image("recipe-image")
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                }
                .overlay {
                    VStack {
                        HStack {
                            Spacer()
                            VStack {
                                HStack(spacing: 5) {
                                    Text("\(Int(recipesDetails.calories ?? 0))")
                                        .foregroundStyle(Color("WhiteFont"))
                                        .font(.custom("PlusJakartaSans-Semibold", size: 15))
                                    Image(systemName: "fork.knife.circle.fill")
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                        .foregroundStyle(Color("WhiteFont"))
                                }
                                HStack(spacing: 5) {
                                    Text("\(Int(recipesDetails.totalTime ?? 0))m")
                                        .foregroundStyle(Color("WhiteFont"))
                                        .font(.custom("PlusJakartaSans-Semibold", size: 15))
                                    Image(systemName: "stopwatch")
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                        .foregroundStyle(Color("WhiteFont"))
                                }
                            }
                            .frame(width: 58, height: 51)
                            .background(Color("Background"))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .overlay {
                                RoundedRectangle(cornerRadius: 3)
                                    .strokeBorder(Color("WhiteFont"), lineWidth: 1)
                            }
                            .padding(.top, 10)
                            .padding(.trailing, 15)
                        }
                        Spacer()
                        Text(recipesDetails.label)
                            .foregroundStyle(Color("WhiteFont"))
                            .font(.custom("PlusJakartaSans-SemiBold", size: 28))
                    }
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ingredients")
                        .foregroundStyle(Color("WhiteFont"))
                        .font(.custom("Gutheng", size: 32))
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(recipesDetails.ingredientLines, id: \.self) { ingredient in
                            Text("- \(ingredient)")
                                .foregroundStyle(Color("WhiteFont"))
                                .font(.custom("Gutheng", size: 16))
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color("Background"))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView()
            }
            ToolbarItem(placement: .principal) {
                Text("Reciplease")
                    .foregroundStyle(Color("WhiteFont"))
                    .font(.custom("Gutheng", size: 25))
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    print("star")
                } label: {
                    Image(systemName: "star")
                }
            }
        }
        .onAppear {
            fetchRecipeByURI(uri: uri) { result in
                switch result {
                case .success(let recipe):
                    DispatchQueue.main.async {
                        self.recipesDetails = recipe
                    }
                case .failure(let error):
                    print("❌ Erreur : \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    RecipeDetailsView(uri: "")
}
