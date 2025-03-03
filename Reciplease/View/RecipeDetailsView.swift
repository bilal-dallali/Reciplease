//
//  RecipeDetailsView.swift
//  Reciplease
//
//  Created by Bilal Dallali on 04/02/2025.
//

import SwiftUI
import CoreData
import SafariServices

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}

struct RecipeDetailsView: View {
    
    let uri: String
    @State private var recipesDetails: RecipeDetails
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isFavorite: Bool = false
    @State private var showNavigator: Bool = false
    var apiGetManager = apiGetRequest()
    
    init(uri: String) {
        self.uri = uri
        // Initialisation avec des valeurs par défaut
        _recipesDetails = State(initialValue: RecipeDetails(label: "Chargement...", image: "", ingredientLines: [], calories: 0.0, totalTime: 0.0, uri: "", url: ""))
    }
    
    func addToFavorites() {
        let recipe = RecipePersistent(context: viewContext)
        recipe.id = UUID()
        recipe.label = recipesDetails.label
        recipe.image = recipesDetails.image
        //recipe.ingredients = try? JSONEncoder().encode(recipesDetails.ingredientLines)
        recipe.ingredients = recipesDetails.ingredientLines as NSObject
        recipe.calories = recipesDetails.calories ?? 0.0
        recipe.totalTime = recipesDetails.totalTime ?? 0.0
        recipe.uri = recipesDetails.uri
        recipe.isFavorite = true
        recipe.url = recipesDetails.url

        do {
            try viewContext.save()
            print("✅ Recette ajoutée aux favoris !")
        } catch {
            print("❌ Erreur lors de l'ajout aux favoris :", error.localizedDescription)
        }
    }

    func removeFromFavorites() {
        let request: NSFetchRequest<RecipePersistent> = RecipePersistent.fetchRequest()
        request.predicate = NSPredicate(format: "uri == %@", recipesDetails.uri)

        do {
            let results = try viewContext.fetch(request)
            for object in results {
                viewContext.delete(object)
            }
            try viewContext.save()
            print("✅ Recette supprimée des favoris !")
        } catch {
            print("❌ Erreur lors de la suppression :", error.localizedDescription)
        }
    }
    
    func checkIfFavorite() {
        let request: NSFetchRequest<RecipePersistent> = RecipePersistent.fetchRequest()
        request.predicate = NSPredicate(format: "uri == %@", recipesDetails.uri)
        
        do {
            let results = try viewContext.fetch(request)
            isFavorite = !results.isEmpty
        } catch {
            print("❌ Erreur lors de la vérification des favoris :", error.localizedDescription)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
            .scrollIndicators(.hidden)
            if !recipesDetails.url.isEmpty {
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
                    if isFavorite {
                        isFavorite = false
                        removeFromFavorites()
                    } else {
                        isFavorite = true
                        addToFavorites()
                    }
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color("GreenFavorite"))
                }
            }
        }
        .onAppear {
            checkIfFavorite()
            apiGetManager.fetchRecipeByURI(uri: uri) { result in
                switch result {
                case .success(let recipe):
                    DispatchQueue.main.async {
                        self.recipesDetails = recipe
                        self.checkIfFavorite()
                    }
                case .failure(let error):
                    print("❌ Erreur : \(error.localizedDescription)")
                }
            }
        }
        .sheet(isPresented: $showNavigator) {
            SafariWebView(url: URL(string: recipesDetails.url)!)
        }
    }
}

#Preview {
    RecipeDetailsView(uri: "")
}
