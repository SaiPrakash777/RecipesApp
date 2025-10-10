//
//  RecipesEntity+CoreDataProperties.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 10/10/25.
//
//

import Foundation
import CoreData


extension RecipesEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipesEntity> {
        return NSFetchRequest<RecipesEntity>(entityName: "RecipesEntity")
    }

    @NSManaged public var cookTimeMinutes: Int32
    @NSManaged public var cuisine: String?
    @NSManaged public var ratings: Double
    @NSManaged public var recipeImage: String?
    @NSManaged public var recipeName: String?
    @NSManaged public var servings: Int32
    @NSManaged public var recipeId: Int32
    @NSManaged public var difficultyStatus: String?

}
