//
//  RecipeDetailsView.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 09/10/25.
//

import SwiftUI

struct RecipeDetailsView: View {
    
    let recipeName: String
    var body: some View {
        Text(recipeName)
    }
}

#Preview {
    RecipeDetailsView(recipeName: "")
}
