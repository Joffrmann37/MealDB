//
//  MealDetailViewModel.swift
//  MealDB
//
//  Created by Joffrey Mann on 4/21/24.
//

import Foundation
import Combine

// MARK - View model is used as datasource for meal details
class MealDetailViewModel: ObservableObject {
    var useCase: FetchMealDetailUseCase
    private var subscriptions = Set<AnyCancellable>()
    var id: String
    @Published var details = [MealDetail]()
    @Published var error: MealDBError?
    @Published var searchText: String = "" {
        didSet {
            fetchItems()
        }
    }
    
    init(useCase: FetchMealDetailUseCase, id: String) {
        self.useCase = useCase
        self.id = id
    }
    
    private func getURL() -> URL {
        return URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(id)")!
    }
        
    func fetchItems<T>(type: T.Type = DetailRoot.self) where T: DetailRoot {
        useCase.fetchDetails(url: getURL()).sink { [unowned self] completion in
            if case let .failure(error) = completion {
                self.error = error
            }
        } receiveValue: { [weak self] root in
            guard let self = self else { return }
            self.details = root.meals
        }.store(in: &subscriptions)
    }
}
