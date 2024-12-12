//
//  Publisher+Async.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/20/23.
//

import Combine

extension Publisher {
    func asyncMap<T>(_ transform: @escaping (Output) async -> T)
    -> Publishers.FlatMap<Future<T, Never>, Self> {
        self.flatMap { value in
            Future { promise in
                Task {
                    let output = await transform(value)
                    promise(.success(output))
                }
            }
        }
    }

    func asyncMap<T>(_ transform: @escaping (Output) async throws -> T)
    -> Publishers.FlatMap<Future<T, Error>, Self> {
        self.flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }

    func asyncMap<T>(
        _ transform: @escaping (Output) async throws -> T)
    -> Publishers.FlatMap<Future<T, Error>, Publishers.SetFailureType<Self, Error>> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}
