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
    @State private var showNavigator: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    init(recipe: RecipePersistent) {
        self.recipe = recipe
        _isFavorite = State(initialValue: recipe.isFavorite)
    }
    
    private func toggleFavorite() {
        isFavorite.toggle()
        
        if isFavorite {
            recipe.isFavorite = true
        } else {
            // Delete the recipe from favorites
            viewContext.delete(recipe)
            presentationMode.wrappedValue.dismiss()
        }
        
        do {
            try viewContext.save()
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
                        Image("recipe-image")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .accessibilityLabel("Image of the recipe \(recipe.label ?? "Unknown")")
                    .overlay {
                        VStack {
                            HStack {
                                Spacer()
                                VStack(spacing: 0) {
                                    HStack(spacing: 5) {
                                        Text("\(Int(recipe.calories))")
                                            .foregroundStyle(Color("WhiteFont"))
                                            .font(.custom("PlusJakartaSans-Semibold", size: 15))
                                            .minimumScaleFactor(0.5)
                                            .accessibilityLabel("Calories: \(Int(recipe.calories))")
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
                                            .accessibilityLabel("Total cooking time: \(Int(recipe.totalTime))")
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
                                .minimumScaleFactor(0.3)
                                .dynamicTypeSize(.xSmall ... .accessibility3)
                                .accessibilityLabel("Recipe title: \(recipe.label ?? "Unknown")")
                        }
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ingredients")
                            .foregroundStyle(Color("WhiteFont"))
                            .font(.custom("Gutheng", size: 32))
                            .minimumScaleFactor(0.5)
                            .accessibilityLabel("Ingredients list")
                        VStack(alignment: .leading, spacing: 0) {
                            if let ingredientsArray = recipe.ingredients as? [String] {
                                ForEach(ingredientsArray, id: \.self) { ingredient in
                                    HStack(spacing: 0) {
                                        Text("- ")
                                            .foregroundStyle(Color("WhiteFont"))
                                            .font(.custom("Gutheng", size: 16))
                                            .minimumScaleFactor(0.4)
                                            .lineLimit(4)
                                        Text("\(ingredient)")
                                            .foregroundStyle(Color("WhiteFont"))
                                            .font(.custom("Gutheng", size: 16))
                                            .minimumScaleFactor(0.4)
                                            .lineLimit(4)
                                    }
                                    .dynamicTypeSize(.xSmall ... .accessibility3)
                                    .accessibilityLabel("Ingredient: \(ingredient)")
                                }
                            } else {
                                Text("No ingredients available")
                                    .foregroundStyle(Color("WhiteFont"))
                                    .font(.custom("Gutheng", size: 16))
                                    .minimumScaleFactor(0.5)
                                    .accessibilityLabel(Text("No ingredients"))
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
            .scrollIndicators(.hidden)
            
            Button {
                showNavigator = true
            } label: {
                Text("Get directions")
                    .foregroundStyle(Color("WhiteFont"))
                    .font(.custom("PlusJakartaSans-Semibold", size: 23))
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color("GreenButton"))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .padding(.horizontal, 35)
                    .padding(.bottom, 75)
                    .minimumScaleFactor(0.5)
            }
            .accessibilityLabel("Open recipe directions")
            .accessibilityHint("Double tap to open the recipe instructions in a browser")
            .accessibilityAddTraits(.isButton)

        }
        .navigationBarBackButtonHidden(true)
        .background(Color("Background"))
        .ignoresSafeArea(edges: .bottom)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView()
                    .accessibilityLabel("Back")
                    .accessibilityHint("Double tap to go back")
                    .accessibilityAddTraits(.isButton)
            }
            ToolbarItem(placement: .principal) {
                Text("Reciplease")
                    .foregroundStyle(Color("WhiteFont"))
                    .font(.custom("Gutheng", size: 25))
                    .minimumScaleFactor(0.5)
                    .accessibilityLabel("Reciplease - Recipe Details")
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
                .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                .accessibilityHint("Double tap to toggle favorite status")
                .accessibilityAddTraits(.isButton)
            }
        }
        .sheet(isPresented: $showNavigator) {
            SafariWebView(url: URL(string: recipe.url!)!)
                .accessibilityLabel("Webpage with recipe instructions")
                .accessibilityHint("Swipe right to navigate in the webpage")
        }
    }
}

#Preview {
    RecipePersistentDetailsView(recipe: .init())
}
