//
//  ShoppingView.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 10/10/25.
//

import SwiftUI

struct ShoppingView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: ImageIcons.cartFillIcon.rawValue)
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                Text("Your shopping list is empty.")
                    .font(.headline)
                    .padding(.top)
            }
            .navigationTitle("Shopping")
        }
    }
}
#Preview {
    ShoppingView()
}
