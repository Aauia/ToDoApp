//
//  BackgroundOperationService.swift
//  ToDo
//
//  Created by Aiaulym Abduohapova on 19.08.2025.
//

import Foundation

class BackgroundOperationService {
    static let shared = BackgroundOperationService()
    
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    private init() {}
    
    // MARK: - Generic Background Operation
    
    func performBackgroundOperation<T>(
        operation: @escaping () throws -> T,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        operationQueue.addOperation {
            do {
                let result = try operation()
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - GCD Background Operations
    
    func performGCDBackgroundOperation<T>(
        operation: @escaping () throws -> T,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try operation()
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Specific ToDo Operations
    
    func saveToDo(
        _ entity: ToDoEntity,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        performBackgroundOperation(
            operation: {
                try CoreDataManager.shared.saveToDo(entity)
                return ()
            },
            completion: completion
        )
    }
    
    func updateToDo(
        _ entity: ToDoEntity,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        performBackgroundOperation(
            operation: {
                try CoreDataManager.shared.updateToDo(entity)
                return ()
            },
            completion: completion
        )
    }
    
    func deleteToDo(
        withId id: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        performBackgroundOperation(
            operation: {
                CoreDataManager.shared.deleteToDo(withId: id)
            },
            completion: completion
        )
    }
    
    func fetchToDos(
        completion: @escaping (Result<[ToDoEntity], Error>) -> Void
    ) {
        performBackgroundOperation(
            operation: {
                return CoreDataManager.shared.fetchAllToDos()
            },
            completion: completion
        )
    }
    
    func searchToDos(
        with searchText: String,
        completion: @escaping (Result<[ToDoEntity], Error>) -> Void
    ) {
        performGCDBackgroundOperation(
            operation: {
                return CoreDataManager.shared.searchToDos(with: searchText)
            },
            completion: completion
        )
    }
}
