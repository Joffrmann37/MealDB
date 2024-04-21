//
//  ContentView.swift
//  MealDB
//
//  Created by Joffrey Mann on 4/21/24.
//

import SwiftUI
import Combine

struct ImageItem: View {
    @State var item: Meal
    
    var body: some View {
        AsyncImage(url: URL(string: $item.wrappedValue.strMealThumb)) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
        .frame(width: 60, height: 60)
    }
}

struct ContentView: View {
    @ObservedObject var vm = MealsViewModel(useCase: FetchMealsUseCase(repository: MealDBRepository()))
    
    var body: some View {
        NavigationView {
            List {
                ForEach($vm.items) { item in
                    let name = item.wrappedValue.strMeal
                    NavigationLink(destination: DetailView(vm: MealDetailViewModel(useCase: FetchMealDetailUseCase(repository: MealDBRepository()), id: item.wrappedValue.idMeal))) {
                        VStack(spacing: 10, content: {
                            let imageItem = ImageItem(item: item.wrappedValue)
                            HStack(spacing: 30) {
                                imageItem
                                Text(name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        })
                    }
                    .navigationBarTitle("Meals")
                }
            }
        }
        .onAppear {
            vm.fetchItems()
        }
    }
}

#Preview {
    ContentView()
}
