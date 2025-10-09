//
//  RecipeAppApp.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 09/10/25.
//

import SwiftUI

@main
struct RecipeAppApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
            .preferredColorScheme(.light) 
        }
    }
}
