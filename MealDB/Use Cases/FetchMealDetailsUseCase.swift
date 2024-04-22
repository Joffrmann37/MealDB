//
//  FetchMealDetailsUseCase.swift
//  MealDB
//
//  Created by Joffrey Mann on 4/21/24.
//

import Foundation
import Combine

// MARK - Represents the use case of fetching meal details
class FetchMealDetailUseCase {
    let repository: Serviceable
    
    init(repository: Serviceable) {
        self.repository = repository
    }
    
    func fetchDetails<T: Decodable>(url: URL, type: T.Type = DetailRoot.self) -> Future<T, MealDBError> where T: DetailRoot  {
        return repository.fetch(url: url, forType: type)
    }
}
