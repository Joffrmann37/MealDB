//
//  MealDBViewModelTests.swift
//  MealDBTests
//
//  Created by Joffrey Mann on 4/21/24.
//

import XCTest
@testable import MealDB
import Combine

final class FlickrItemsViewModelTests: XCTestCase {
    func test_DidGetItemsJSON() {
        let vm = MealsViewModelSpy(useCase: FetchMealsUseCase(repository: MealDBRepositorySpy()))
        let exp = expectation(description: "Wait for task")
        let expectedItems = testWithExpectation(vm: vm, exp: exp)
        XCTAssertTrue(expectedItems.count > 0)
    }
    
    private func testWithExpectation(vm: MealsViewModelSpy, exp: XCTestExpectation, timeout: Double = 3, file: StaticString = #file, line: UInt = #line) -> [Meal] {
        var itemsToCompare = [Meal]()
        vm.fetchItems()
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            _ = vm.$items.sink { items in
                itemsToCompare = items
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: timeout)
        return itemsToCompare
    }
    
    private class MealsViewModelSpy: MealsViewModel {
        private var subscriptions = Set<AnyCancellable>()
        
        override init(useCase: FetchMealsUseCase, url: URL = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert")!) {
            super.init(useCase: useCase, url: url)
            self.useCase = useCase
            self.url = url
        }
        
        override func fetchItems<T>(type: T.Type = Root.self) where T: Root  {
            return useCase.fetchItems(url: url, type: type).sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.error = error
                }
            } receiveValue: { [weak self] root in
                guard let self = self else { return }
                self.items = root.meals
            }.store(in: &subscriptions)
        }
    }
    
    private class RootSpy: Root {}
    
    private class MealDBRepositorySpy: Serviceable {
        var subscriptions = Set<AnyCancellable>()
        
        func fetch<T>(url: URL, forType type: T.Type) -> Future<T, MealDBError> where T : Decodable {
            return Future<T, MealDBError> { [unowned self] promise in
                URLSession(configuration: .default).dataTaskPublisher(for: url)
                    .tryMap { (data: Data, response: URLResponse) in
                        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 200 || httpResponse.statusCode > 299 {
                            throw MealDBError(rawValue: httpResponse.statusCode)!
                        }
                        return data
                    }
                    .decode(type: type,
                            decoder: JSONDecoder())
                    .receive(on: RunLoop.main)
                    .sink { completion in
                        if case .failure(_) = completion {
                            promise(.failure(.badRequest))
                        }
                    }
            receiveValue: {
                promise(.success($0))
            }
            .store(in: &self.subscriptions)
                
            }
        }
    }
}
