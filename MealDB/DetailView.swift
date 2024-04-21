//
//  DetailView.swift
//  MealDB
//
//  Created by Joffrey Mann on 4/21/24.
//

import SwiftUI

struct ImageDetailItem: View {
    @State var item: MealDetail
    
    var body: some View {
        AsyncImage(url: URL(string: $item.wrappedValue.strMealThumb)) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
        .frame(width: 120, height: 120)
    }
}

struct DetailView: View {
    @ObservedObject var vm: MealDetailViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    if $vm.details.count > 0 {
                        let imageItem = ImageDetailItem(item: $vm.details[0].wrappedValue)
                        imageItem
                            .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0  ))
                        Text("Instructions")
                            .fontWeight(.bold)
                            .padding(.init(top: 20, leading: 0, bottom: 0, trailing: 0  ))
                        Text(($vm.details[0].wrappedValue.strInstructions))
                            .padding(.init(top: 10, leading: 20, bottom: 0, trailing: 20))
                        Text("Ingredients")
                            .fontWeight(.bold)
                            .padding(.init(top: 20, leading: 0, bottom: 0, trailing: 0  ))
                        Text($vm.details[0].wrappedValue.strIngredient1)
                            .padding(.init(top: 20, leading: 0, bottom: 0, trailing: 0  ))
                        Text($vm.details[0].wrappedValue.strIngredient2)
                        Text($vm.details[0].wrappedValue.strIngredient3)
                        Text($vm.details[0].wrappedValue.strIngredient4)
                        Text($vm.details[0].wrappedValue.strIngredient5)
                        Text($vm.details[0].wrappedValue.strIngredient6)
                        Text("Measurements")
                            .fontWeight(.bold)
                            .padding(.init(top: 20, leading: 0, bottom: 0, trailing: 0  ))
                        Text($vm.details[0].wrappedValue.strMeasure1)
                            .padding(.init(top: 20, leading: 0, bottom: 0, trailing: 0  ))
                        Text($vm.details[0].wrappedValue.strMeasure2)
                        Text($vm.details[0].wrappedValue.strMeasure3)
                        Text($vm.details[0].wrappedValue.strMeasure4)
                        Text($vm.details[0].wrappedValue.strMeasure5)
                        Text($vm.details[0].wrappedValue.strMeasure6)
                    } else {
                        Text("Loading...")
                    }
                }
                .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
        .navigationBarTitle($vm.details.count > 0 ? $vm.details[0].wrappedValue.strMeal : "Detail")
        .onAppear {
            vm.fetchItems()
        }
    }
}

#Preview {
    DetailView(vm: MealDetailViewModel(useCase: FetchMealDetailUseCase(repository: MealDBRepository()), id: "53049"))
}
