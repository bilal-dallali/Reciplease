//
//  CoreDataTests.swift
//  RecipleaseTests
//
//  Created by Bilal Dallali on 22/02/2025.
//

import XCTest
import CoreData
@testable import Reciplease

final class CoreDataTests: XCTestCase {
    
    var persistentContainer: NSPersistentContainer!
    var managedContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        persistentContainer = NSPersistentContainer(name: "Reciplease")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null") // Simule une base de données en mémoire
        persistentContainer.persistentStoreDescriptions = [description]
        
        let expectation = self.expectation(description: "PersistentContainerLoad")
        persistentContainer.loadPersistentStores { (_, error) in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
        
        managedContext = persistentContainer.viewContext
    }
    
    override func tearDown() {
        persistentContainer = nil
        managedContext = nil
        super.tearDown()
    }
    
    func testAddRecipeToFavorites() {
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
            XCTFail("Échec de l'ajout de la recette aux favoris: \(error.localizedDescription)")
        }
        
        let fetchRequest: NSFetchRequest<RecipePersistent> = RecipePersistent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uri == %@", "test_uri")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            XCTAssertEqual(results.count, 1, "La recette n'a pas été ajoutée correctement")
            XCTAssertEqual(results.first?.label, "Test Recipe", "Le nom de la recette ne correspond pas")
        } catch {
            XCTFail("Erreur lors de la récupération de la recette: \(error.localizedDescription)")
        }
    }
    
    func testRemoveRecipeFromFavorites() {
        let recipe = RecipePersistent(context: managedContext)
        recipe.id = UUID()
        recipe.label = "Test Recipe"
        recipe.uri = "test_uri"
        recipe.isFavorite = true
        
        do {
            try managedContext.save()
        } catch {
            XCTFail("Échec de l'ajout de la recette aux favoris: \(error.localizedDescription)")
        }
        
        let fetchRequest: NSFetchRequest<RecipePersistent> = RecipePersistent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uri == %@", "test_uri")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            XCTAssertFalse(results.isEmpty, "Aucune recette trouvée avant suppression")
            
            for object in results {
                managedContext.delete(object)
            }
            try managedContext.save()
            
            let newResults = try managedContext.fetch(fetchRequest)
            XCTAssertTrue(newResults.isEmpty, "La recette n'a pas été supprimée correctement")
        } catch {
            XCTFail("Erreur lors de la suppression de la recette: \(error.localizedDescription)")
        }
    }
    
    func testCheckIfRecipeIsFavorite() {
        let recipe = RecipePersistent(context: managedContext)
        recipe.id = UUID()
        recipe.label = "Test Recipe"
        recipe.uri = "test_uri"
        recipe.isFavorite = true
        
        do {
            try managedContext.save()
        } catch {
            XCTFail("Erreur lors de l'ajout de la recette : \(error.localizedDescription)")
        }
        
        let fetchRequest: NSFetchRequest<RecipePersistent> = RecipePersistent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uri == %@", "test_uri")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            XCTAssertTrue(!results.isEmpty, "La recette devrait être dans les favoris")
        } catch {
            XCTFail("Erreur lors de la récupération de la recette: \(error.localizedDescription)")
        }
    }
    
    func testUpdateRecipeFavoriteStatus() {
        let recipe = RecipePersistent(context: managedContext)
        recipe.id = UUID()
        recipe.label = "Test Recipe"
        recipe.uri = "test_uri"
        recipe.isFavorite = true

        try? managedContext.save()

        // Récupérer et modifier
        let fetchRequest: NSFetchRequest<RecipePersistent> = RecipePersistent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uri == %@", "test_uri")

        if let fetchedRecipe = try? managedContext.fetch(fetchRequest).first {
            fetchedRecipe.isFavorite = false
            try? managedContext.save()
        }

        // Vérifier la modification
        let updatedRecipe = try? managedContext.fetch(fetchRequest).first
        XCTAssertFalse(updatedRecipe?.isFavorite ?? true, "Le statut favori n'a pas été mis à jour")
    }
    
}
