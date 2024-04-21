//
//  FetchMealsUseCase.swift
//  MealDB
//
//  Created by Joffrey Mann on 4/21/24.
//

import Foundation
import Combine

class FetchMealsUseCase {
    let repository: Serviceable
    
    init(repository: Serviceable) {
        self.repository = repository
    }
    
    func fetchItems<T: Decodable>(url: URL, type: T.Type = Root.self) -> Future<T, MealDBError> where T: Root  {
        return repository.fetch(url: url, forType: type)
    }
}
