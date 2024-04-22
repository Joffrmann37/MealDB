//
//  MealDBViewModel.swift
//  MealDB
//
//  Created by Joffrey Mann on 4/21/24.
//

import Foundation
import Combine

// MARK - View model is used as datasource for meal listings
class MealsViewModel: ObservableObject {
    var useCase: FetchMealsUseCase
    private var subscriptions = Set<AnyCancellable>()
    var url: URL = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert")!
    @Published var items = [Meal]()
    @Published var error: MealDBError?
    @Published var searchText: String = "" {
        didSet {
            fetchItems()
        }
    }
    
    init(useCase: FetchMealsUseCase, url: URL = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert")!) {
        self.useCase = useCase
        self.url = url
    }
    
    private func getURL() -> URL {
        return URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert")!
    }
        
    func fetchItems<T>(type: T.Type = Root.self) where T: Root {
        useCase.fetchItems(url: getURL()).sink { [unowned self] completion in
            if case let .failure(error) = completion {
                self.error = error
            }
        } receiveValue: { [weak self] root in
            guard let self = self else { return }
            self.items = root.meals
        }.store(in: &subscriptions)
    }
}
