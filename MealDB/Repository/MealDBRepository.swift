//
//  MealDBRepository.swift
//  MealDB
//
//  Created by Joffrey Mann on 4/21/24.
//

import Foundation
import Combine

// MARK - Enum used to represent error cases
enum MealDBError: Int, Swift.Error {
    case badRequest = 400
    case forbidden = 403
    case notFound = 404
    case serverError = 500
    case notAcceptable = 406
}

// MARK - Protocol that any repository would use to make service calls. Returns a Future which is similar to a promise in JS.
protocol Serviceable {
    func fetch<T>(url: URL, forType type: T.Type) -> Future<T, MealDBError> where T : Decodable
}

class MealDBRepository {
    var subscriptions = Set<AnyCancellable>()
}

extension MealDBRepository: Serviceable {
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
                    if case let .failure(error) = completion, let error = error as? MealDBError {
                        promise(.failure(error))
                    }
                }
        receiveValue: {
            promise(.success($0))
        }
        .store(in: &self.subscriptions)
            
        }
    }
}
