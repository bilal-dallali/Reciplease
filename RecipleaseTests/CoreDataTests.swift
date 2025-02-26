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
        description.url = URL(fileURLWithPath: "/dev/null") // Simule une base de données en mémoire
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
        // Assurez-vous que `managedContext` est bien initialisé
        XCTAssertNotNil(managedContext, "Le managedContext n'a pas été initialisé correctement")

        // Utilisation de la méthode addToFavorites avec les valeurs statiques déjà présentes dans la fonction
        dataController.addToFavorites(Recipe(
            label: "Test Recipe",
            image: "test_image_url",
            ingredientLines: ["Tomato", "Onion"],
            totalTime: 20,
            uri: "test_uri",
            calories: 100,
            url: "https://example.com"
        ))

        // Vérification que la recette a bien été ajoutée dans Core Data avec l'URI statique
        let fetchRequest: NSFetchRequest<RecipePersistent> = RecipePersistent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uri == %@", "test_uri") // Vérification avec l'URI statique
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            // Vérification qu'on a bien une recette ajoutée
            XCTAssertEqual(results.count, 1, "La recette n'a pas été ajoutée aux favoris")
            
            // Vérification de la présence de la recette avant utilisation
            guard let savedRecipe = results.first else {
                XCTFail("Aucune recette trouvée")
                return
            }
            
            // Vérification des attributs de la recette sauvegardée
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
