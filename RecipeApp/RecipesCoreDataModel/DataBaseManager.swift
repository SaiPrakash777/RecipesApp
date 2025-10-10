//
//  DataBaseManager.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 09/10/25.
//

import Foundation
import CoreData

class DBManager{
    static let sharedInstance = DBManager()
    
    lazy var context = persistentContainer.viewContext
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RecipesCDContainer")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func fetchRecipesData() -> [RecipesEntity]{
        var recipes = [RecipesEntity]()
        let fetchRuquest = NSFetchRequest<NSFetchRequestResult>(entityName: RecipesEntity.description())
        do{
            recipes = try context.fetch(fetchRuquest) as! [RecipesEntity]
        }catch{
            print(" ===> error error error")
        }
        return recipes
    }
    func createRecipeRecord(record: Recipes) {
        let context = DBManager.sharedInstance.context
        let recipes = RecipesEntity(context: context)
        recipes.recipeName = record.name
        recipes.recipeImage = record.image
        recipes.cookTimeMinutes = Int32(record.cookTimeMinutes ?? 0)
        recipes.servings = Int32(record.servings ?? 0)
        recipes.ratings = record.rating ?? 0
        recipes.cuisine = record.cuisine
        recipes.recipeId = Int32(record.id ?? 0)
        recipes.difficultyStatus = record.difficulty
        DBManager.sharedInstance.saveContext()
    }
    func deleteRecipeRecord(recipeId: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: RecipesEntity.description())
        fetchRequest.predicate = NSPredicate(format: "recipeId == %d", recipeId)
        
        do {
            let records = try persistentContainer.viewContext.fetch(fetchRequest)
            if let recordToDelete = records.first {
                persistentContainer.viewContext.delete(recordToDelete as! NSManagedObject)
                try persistentContainer.viewContext.save()
                print("Recipe deleted with id: \(recipeId)")
            }
        } catch {
            print("Failed to delete recipe: \(error.localizedDescription)")
        }
    }

}
