//
//  DataController.swift
//  Reciplease
//
//  Created by Bilal Dallali on 11/02/2025.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container: NSPersistentContainer
    private let managedContext: NSManagedObjectContext
    
    init(container: NSPersistentContainer = NSPersistentContainer(name: "Reciplease")) {
        //let container = NSPersistentContainer(name: "Reciplease")
        self.container = container
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Unresolved error \(error.localizedDescription)")
            }
        }
        managedContext = container.viewContext
        
    }
    
    func isFavorite(_ recipe: Recipe) -> Bool {
        return false
    }
    
    func getFavorites() -> [Recipe] {
        return []
    }
    
    func addToFavorites(_ recipe: Recipe) {
        let recipe = RecipePersistent(context: managedContext)
        recipe.id = UUID()
        recipe.label = "Test Recipe"
        recipe.image = "test_image_url"
        recipe.ingredients = ["Tomate", "Oignon"] as NSObject
        recipe.calories = 100
        recipe.totalTime = 20
        recipe.uri = "test_uri"
        recipe.isFavorite = true
        
        do {
            try managedContext.save()
        } catch {
            //XCTFail("Échec de l'ajout de la recette aux favoris: \(error.localizedDescription)")
        }
    }
}
