//
//  RecipeDetailsView.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 09/10/25.
//

import SwiftUI

struct RecipeDetailsView<VM: RecipesDetailsVM>: View {
    @StateObject var recipesDetailsVM: VM
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var loader = ImageLoader()
    let recipeName: String
    @State private var hasLoaded = false
    var body: some View {
        ZStack {
            if recipesDetailsVM.isSuccess && !recipesDetailsVM.recipes.isEmpty {
                detailsView()
            } else if recipesDetailsVM.errorMessage != nil {
                Text(recipesDetailsVM.errorMessage ?? "error")
                    .foregroundColor(.red)
            } else {
                VStack{
                    Text("No Recipe Details Available")
                }
            }
        }
        .task {
            if !hasLoaded {
                hasLoaded = true
                await recipesDetailsVM.fetchRecipesDataWithUrlEndPoint(urlEndPoint: recipeName)
            }
        }
    }
}


extension RecipeDetailsView{
    @ViewBuilder
    func detailsView() -> some View{
        ScrollView{
            let recipeDetails = recipesDetailsVM.recipes.first
            VStack(alignment: .leading, spacing: 10) {
                Image(uiImage: loader.image ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .onAppear {
                                loader.loadImage(fromUrl: recipeDetails?.image, placeholderImage: "Recipes")
                            }
                Text(recipeDetails?.name ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let time = recipeDetails{
                    timeAndRating(recipeDetails: time)
                }
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: ImageIcons.starIcon.rawValue)
                            .foregroundColor(.orange)
                        Text(String(format: "%.1f", recipeDetails?.rating ?? 0))
                            .font(.subheadline)
                    }
                    Text("(\(recipeDetails?.reviewCount ?? 0) reviews)")
                }
                tagsScrollView(tags: recipeDetails?.tags ?? [])
                Text("Nutrition (per serving)")
                    .fontWeight(.bold)
                if let nutrition = recipeDetails{
                    nutritionDetails(recipeDetails: nutrition)
                }
                Text("Ingrediants")
                    .fontWeight(.bold)
                VStack{
                    ForEach(recipeDetails?.ingredients ?? [], id: \.self) { index in
                        HStack {
                            Text("•")
                            Text(index)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(1.5), lineWidth: 1)
                    )
                }
                .padding(.bottom, 15)

                Text("Instructions")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.bottom, 0)

                VStack(alignment: .leading, spacing: 0) {
                    if let instructions = recipeDetails?.instructions as? [String] {
                        ForEach(instructions.indices, id: \.self) { i in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(i + 1)")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Circle().fill(Color.blue))
                                
                                Text(instructions[i])
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("Recipe Details", displayMode: .inline)
        .navigationBarBackButtonHidden(true) // Hide default back button
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss() // Go back
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        })
    }
    func calculateProteinAndCarbs(
        caloriesPerServing: Double,
        servings: Int) -> (Double,Double) {
        let proteinRatio: Double = 0.3
        let carbsRatio: Double = 0.5
        let proteinCalories = caloriesPerServing * proteinRatio
        let carbsCalories = caloriesPerServing * carbsRatio
        
        let proteinGrams = proteinCalories / 4
        let carbsGrams = carbsCalories / 4
        
        return (proteinGrams,carbsGrams)
    }
}
extension RecipeDetailsView{
    @ViewBuilder
    func tagsScrollView(tags: [String]) -> some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            .padding(.vertical, 4)
        }
    }
    @ViewBuilder
    func timeAndRating(recipeDetails: Recipes) -> some View{
        
        HStack(spacing: 8) {
            HStack(spacing: 3) {
                Image(systemName: ImageIcons.clockIcon.rawValue)
                    .foregroundColor(.gray)
                Text("\(recipeDetails.cookTimeMinutes ?? 0) min")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text("•")
            HStack(spacing: 3) {
                Image(systemName: ImageIcons.forkAndKnifeIcon.rawValue)
                    .foregroundColor(.gray)
                Text("\(recipeDetails.servings ?? 0) servings")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            Text("•")
            Text("\(recipeDetails.difficulty ?? "")")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .font(.caption)
        .foregroundColor(.gray)
    }
    @ViewBuilder
    func nutritionDetails(recipeDetails: Recipes) -> some View{
        let nutritionDetials = calculateProteinAndCarbs(caloriesPerServing: Double(Int(recipeDetails.caloriesPerServing ?? 0)), servings: recipeDetails.servings ?? 0)
        HStack(spacing: 20) {
            HStack(spacing: 1) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.red)
                Text("\(recipeDetails.caloriesPerServing ?? 0) cal")
                    .foregroundColor(.gray)
            }

            HStack(spacing: 1) {
                Image(systemName: "figure.mind.and.body")
                    .foregroundColor(.red)
                Text("\(String(format: "%.1f", nutritionDetials.0)) protien")
                    .foregroundColor(.gray)
            }

            HStack(spacing: 1) {
                Image(systemName: "birthday.cake.fill")
                    .foregroundColor(.red)
                Text("\(String(format: "%.1f", nutritionDetials.1))g carbs")
                    .foregroundColor(.gray)
            }
        }
        .font(.subheadline)
        .padding(.bottom,15)
    }
}
struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecipeDetailsView(recipesDetailsVM: RecipesDetailsVM(networkService: NetworkClass()),
                              recipeName: "")
        }
    }
}

