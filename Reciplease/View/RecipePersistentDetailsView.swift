//
//  RecipePersistentDetailsView.swift
//  Reciplease
//
//  Created by Bilal Dallali on 15/02/2025.
//

import SwiftUI
import CoreData

struct RecipePersistentDetailsView: View {
    
    let recipe: RecipePersistent
    @State private var isFavorite: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    
    init(recipe: RecipePersistent) {
        self.recipe = recipe
        _isFavorite = State(initialValue: recipe.isFavorite)
    }
    
    private func toggleFavorite() {
        isFavorite.toggle()
        
        if isFavorite {
            recipe.isFavorite = true
        } else {
            // ❌ Supprime la recette des favoris
            viewContext.delete(recipe)
        }
        
        do {
            try viewContext.save() // ✅ Sauvegarde Core Data
        } catch {
            print("❌ Erreur lors de la sauvegarde : \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    AsyncImage(url: URL(string: recipe.image ?? "")) { image in
                        image
                            .resizable()
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                    } placeholder: {
                        Rectangle()
                            .foregroundStyle(Color("GreyFont"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                    }
                    .overlay {
                        VStack {
                            HStack {
                                Spacer()
                                VStack {
                                    HStack(spacing: 5) {
                                        Text("\(Int(recipe.calories))")
                                            .foregroundStyle(Color("WhiteFont"))
                                            .font(.custom("PlusJakartaSans-Semibold", size: 15))
                                        Image(systemName: "fork.knife.circle.fill")
                                            .resizable()
                                            .frame(width: 14, height: 14)
                                            .foregroundStyle(Color("WhiteFont"))
                                    }
                                    HStack(spacing: 5) {
                                        Text("\(Int(recipe.totalTime))m")
                                            .foregroundStyle(Color("WhiteFont"))
                                            .font(.custom("PlusJakartaSans-Semibold", size: 15))
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
                            }
                            Spacer()
                            Text(recipe.label ?? "No recipe selected")
                                .foregroundStyle(Color("WhiteFont"))
                                .font(.custom("PlusJakartaSans-SemiBold", size: 28))
                        }
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ingredients")
                            .foregroundStyle(Color("WhiteFont"))
                            .font(.custom("Gutheng", size: 32))
                        VStack(alignment: .leading, spacing: 0) {
                            if let ingredientsArray = recipe.ingredients as? [String] {
                                ForEach(ingredientsArray, id: \.self) { ingredient in
                                    Text("- \(ingredient)")
                                        .foregroundStyle(Color("WhiteFont"))
                                        .font(.custom("Gutheng", size: 16))
                                }
                            } else {
                                Text("Aucun ingrédients")
                                    .foregroundStyle(Color("WhiteFont"))
                                    .font(.custom("Gutheng", size: 16))
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
            .scrollIndicators(.hidden)
            
            if let urlString = recipe.url, !urlString.isEmpty, let url = URL(string: urlString) {
                Link(destination: url) {
                    Text("Get directions")
                        .foregroundStyle(Color("WhiteFont"))
                        .font(.custom("PlusJakartaSans-Semibold", size: 23))
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Color("GreenButton"))
                        .cornerRadius(3)
                        .padding(.horizontal, 35)
                        .padding(.bottom, 25)
                }
            } else {
                Text("Aucune direction disponible")
                    .foregroundStyle(Color.gray)
                    .font(.custom("PlusJakartaSans-Semibold", size: 18))
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(3)
                    .padding(.horizontal, 35)
                    .padding(.bottom, 25)
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
                    toggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color("GreenFavorite"))
                }
            }
        }
    }
}

#Preview {
    RecipePersistentDetailsView(recipe: .init())
}
