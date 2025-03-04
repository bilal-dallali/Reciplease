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
    var dataController: DataController!
    
    override func setUp() {
        super.setUp()
        
        persistentContainer = NSPersistentContainer(name: "Reciplease")
        let description = NSPersistentStoreDescription()
        // Simulate a DB
        description.url = URL(fileURLWithPath: "/dev/null")
        persistentContainer.persistentStoreDescriptions = [description]
        
        let expectation = self.expectation(description: "PersistentContainerLoad")
        
        persistentContainer.loadPersistentStores { (_, error) in
            XCTAssertNil(error, "Le magasin persistant n'a pas pu être chargé : \(error?.localizedDescription ?? "Aucune erreur")")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("Le magasin persistant a mis trop de temps à se charger : \(error.localizedDescription)")
            }
        }
        
        dataController = DataController(container: persistentContainer)
        managedContext = persistentContainer.viewContext
        
        XCTAssertNotNil(managedContext, "Le managedContext n'a pas été initialisé correctement")
    }
    
    override func tearDown() {
        persistentContainer = nil
        managedContext = nil
        super.tearDown()
    }
    
    func testAddToFavorites() {
        // Chcek if managedcontext is initialised
        XCTAssertNotNil(managedContext, "Le managedContext n'a pas été initialisé correctement")

        // Using the method addToFavorite with static values already in the function
        dataController.addToFavorites(Recipe(
            label: "Test Recipe",
            image: "test_image_url",
            ingredientLines: ["Tomato", "Onion"],
            totalTime: 20,
            uri: "test_uri",
            calories: 100,
            url: "https://example.com"
        ))

        // Check if the recipe has been added to core data with a static uri
        let fetchRequest: NSFetchRequest<RecipePersistent> = RecipePersistent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uri == %@", "test_uri") // Vérification avec l'URI statique
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            // Check if the recipe was addede
            XCTAssertEqual(results.count, 1, "La recette n'a pas été ajoutée aux favoris")
            
            // Check if the recipe was there before being used
            guard let savedRecipe = results.first else {
                XCTFail("Aucune recette trouvée")
                return
            }
            
            // Check the attributes of the saved recipe
            XCTAssertEqual(savedRecipe.label, "Test Recipe", "Le label de la recette n'est pas correct")
            XCTAssertEqual(savedRecipe.uri, "test_uri", "L'URI de la recette n'est pas correct")
            XCTAssertEqual(savedRecipe.isFavorite, true, "La recette n'est pas marquée comme favorite")
            
        } catch {
            XCTFail("Erreur lors de la récupération de la recette : \(error.localizedDescription)")
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

        // Get and update
        let fetchRequest: NSFetchRequest<RecipePersistent> = RecipePersistent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uri == %@", "test_uri")

        if let fetchedRecipe = try? managedContext.fetch(fetchRequest).first {
            fetchedRecipe.isFavorite = false
            try? managedContext.save()
        }

        // Check the update
        let updatedRecipe = try? managedContext.fetch(fetchRequest).first
        XCTAssertFalse(updatedRecipe?.isFavorite ?? true, "Le statut favori n'a pas été mis à jour")
    }
    
    func testGetFavorites() {
        // Check if the favorite list is empty
        XCTAssertEqual(dataController.getFavorites().count, 0, "La liste des favoris devrait être vide au départ")

        // Add a recipe to favorite
        dataController.addToFavorites(Recipe(
            label: "Test Recipe",
            image: "test_image_url",
            ingredientLines: ["Tomato", "Onion"],
            totalTime: 20,
            uri: "test_uri",
            calories: 100,
            url: "https://example.com"
        ))

        // Get favorite after adding one
        let favorites = dataController.getFavorites()

        // Check if there is a favorite
        XCTAssertEqual(favorites.count, 1, "Une recette aurait dû être ajoutée aux favoris")

        // Check if the values match
        XCTAssertEqual(favorites.first?.label, "Test Recipe", "Le label du favori est incorrect")
        XCTAssertEqual(favorites.first?.uri, "test_uri", "L'URI du favori est incorrect")
    }

    func testIsFavorite() {
        let recipe = Recipe(
            label: "Test Recipe",
            image: "test_image_url",
            ingredientLines: ["Tomato", "Onion"],
            totalTime: 20,
            uri: "test_uri",
            calories: 100,
            url: "https://example.com"
        )

        // Check if the recipe isn't favorite at the beginning
        XCTAssertFalse(dataController.isFavorite(recipe), "La recette ne devrait pas être favorite au départ")

        // Add the recipe to favorite
        dataController.addToFavorites(recipe)

        // Check if the recipe is now favorite
        XCTAssertTrue(dataController.isFavorite(recipe), "La recette aurait dû être marquée comme favorite")
    }
    
}
