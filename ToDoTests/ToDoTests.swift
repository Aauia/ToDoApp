//
//  ToDoTests.swift
//  ToDoTests
//
//  Created by Aiaulym Abduohapova on 19.08.2025.
//

import XCTest
import CoreData
import Combine
@testable import ToDo

final class ToDoTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    var networkService: MockNetworkService!
    var backgroundService: BackgroundOperationService!
    
    override func setUpWithError() throws {
        // Set up in-memory Core Data stack for testing
        coreDataManager = CoreDataManager.shared
        networkService = MockNetworkService()
        backgroundService = BackgroundOperationService.shared
    }
    
    override func tearDownWithError() throws {
        // Clean up
        coreDataManager.clearAllData()
        coreDataManager = nil
        networkService = nil
        backgroundService = nil
    }
    
    // MARK: - Entity Tests
    
    func testToDoEntityCreation() throws {
        let todo = ToDoEntity(
            title: "Test Todo",
            description: "Test Description",
            isCompleted: false
        )
        
        XCTAssertFalse(todo.id.isEmpty)
        XCTAssertEqual(todo.title, "Test Todo")
        XCTAssertEqual(todo.description, "Test Description")
        XCTAssertFalse(todo.isCompleted)
        XCTAssertNotNil(todo.createdDate)
    }
    
    // MARK: - Core Data Tests
    
    func testSaveToDo() throws {
        let todo = ToDoEntity(
            title: "Test Save",
            description: "Test Save Description"
        )
        
        coreDataManager.saveToDo(todo)
        
        let savedTodos = coreDataManager.fetchAllToDos()
        XCTAssertEqual(savedTodos.count, 1)
        XCTAssertEqual(savedTodos.first?.title, "Test Save")
    }
    
    func testUpdateToDo() throws {
        let todo = ToDoEntity(
            title: "Original Title",
            description: "Original Description"
        )
        
        coreDataManager.saveToDo(todo)
        
        let updatedTodo = ToDoEntity(
            id: todo.id,
            title: "Updated Title",
            description: "Updated Description",
            createdDate: todo.createdDate,
            isCompleted: true
        )
        
        coreDataManager.updateToDo(updatedTodo)
        
        let savedTodos = coreDataManager.fetchAllToDos()
        XCTAssertEqual(savedTodos.count, 1)
        XCTAssertEqual(savedTodos.first?.title, "Updated Title")
        XCTAssertTrue(savedTodos.first?.isCompleted ?? false)
    }
    
    func testDeleteToDo() throws {
        let todo = ToDoEntity(
            title: "To Delete",
            description: "Will be deleted"
        )
        
        coreDataManager.saveToDo(todo)
        XCTAssertEqual(coreDataManager.fetchAllToDos().count, 1)
        
        coreDataManager.deleteToDo(withId: todo.id)
        XCTAssertEqual(coreDataManager.fetchAllToDos().count, 0)
    }
    
    func testSearchToDos() throws {
        let todo1 = ToDoEntity(title: "Buy groceries", description: "Milk and bread")
        let todo2 = ToDoEntity(title: "Walk dog", description: "In the park")
        let todo3 = ToDoEntity(title: "Read book", description: "Science fiction novel")
        
        coreDataManager.saveToDo(todo1)
        coreDataManager.saveToDo(todo2)
        coreDataManager.saveToDo(todo3)
        
        let searchResults = coreDataManager.searchToDos(with: "dog")
        XCTAssertEqual(searchResults.count, 1)
        XCTAssertEqual(searchResults.first?.title, "Walk dog")
        
        let milkResults = coreDataManager.searchToDos(with: "milk")
        XCTAssertEqual(milkResults.count, 1)
        XCTAssertEqual(milkResults.first?.title, "Buy groceries")
    }
}

// MARK: - Mock Network Service

class MockNetworkService: NetworkServiceProtocol {
    var shouldReturnError = false
    var mockTodos: [ToDoEntity] = []
    
    func fetchToDos() -> AnyPublisher<[ToDoEntity], Error> {
        if shouldReturnError {
            return Fail(error: NetworkError.networkError(NSError(domain: "Test", code: 0)))
                .eraseToAnyPublisher()
        }
        
        let defaultTodos = [
            ToDoEntity(title: "Mock Todo 1", description: "Mock Description 1"),
            ToDoEntity(title: "Mock Todo 2", description: "Mock Description 2")
        ]
        
        return Just(mockTodos.isEmpty ? defaultTodos : mockTodos)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
