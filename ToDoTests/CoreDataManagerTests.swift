import XCTest
import CoreData
@testable import ToDo

final class CoreDataManagerTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    var testContainer: NSPersistentContainer!
    
    override func setUpWithError() throws {
        // Create an in-memory Core Data stack for testing
        testContainer = NSPersistentContainer(name: "ToDoDataModel")
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        testContainer.persistentStoreDescriptions = [description]
        
        testContainer.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        coreDataManager = CoreDataManager()
        // Replace the persistent container with our test container
        coreDataManager.persistentContainer = testContainer
    }
    
    override func tearDownWithError() throws {
        coreDataManager = nil
        testContainer = nil
    }
    
    func testSaveNewToDo() throws {
        let testTodo = ToDoEntity(
            title: "Test Todo",
            description: "Test Description",
            isCompleted: false
        )
        
        coreDataManager.saveToDo(testTodo)
        
        let fetchedTodos = coreDataManager.fetchAllToDos()
        XCTAssertEqual(fetchedTodos.count, 1)
        XCTAssertEqual(fetchedTodos.first?.title, "Test Todo")
        XCTAssertEqual(fetchedTodos.first?.description, "Test Description")
        XCTAssertFalse(fetchedTodos.first?.isCompleted ?? true)
    }
    
    func testUpdateExistingToDo() throws {
        // First save a todo
        let originalTodo = ToDoEntity(
            id: "test-id",
            title: "Original Title",
            description: "Original Description",
            isCompleted: false
        )
        coreDataManager.saveToDo(originalTodo)
        
        // Then update it
        let updatedTodo = ToDoEntity(
            id: "test-id",
            title: "Updated Title",
            description: "Updated Description",
            isCompleted: true
        )
        coreDataManager.updateToDo(updatedTodo)
        
        let fetchedTodos = coreDataManager.fetchAllToDos()
        XCTAssertEqual(fetchedTodos.count, 1)
        XCTAssertEqual(fetchedTodos.first?.title, "Updated Title")
        XCTAssertEqual(fetchedTodos.first?.description, "Updated Description")
        XCTAssertTrue(fetchedTodos.first?.isCompleted ?? false)
    }
    
    func testDeleteToDo() throws {
        let testTodo = ToDoEntity(
            id: "test-id",
            title: "Test Todo",
            description: "Test Description"
        )
        
        coreDataManager.saveToDo(testTodo)
        XCTAssertEqual(coreDataManager.fetchAllToDos().count, 1)
        
        coreDataManager.deleteToDo(withId: "test-id")
        XCTAssertEqual(coreDataManager.fetchAllToDos().count, 0)
    }
    
    func testSearchToDos() throws {
        let todo1 = ToDoEntity(title: "Buy groceries", description: "Milk, bread, eggs")
        let todo2 = ToDoEntity(title: "Walk the dog", description: "Take Rex for a walk")
        let todo3 = ToDoEntity(title: "Study Swift", description: "Learn about protocols")
        
        coreDataManager.saveToDo(todo1)
        coreDataManager.saveToDo(todo2)
        coreDataManager.saveToDo(todo3)
        
        // Search by title
        let searchResults1 = coreDataManager.searchToDos(with: "groceries")
        XCTAssertEqual(searchResults1.count, 1)
        XCTAssertEqual(searchResults1.first?.title, "Buy groceries")
        
        // Search by description
        let searchResults2 = coreDataManager.searchToDos(with: "walk")
        XCTAssertEqual(searchResults2.count, 1)
        XCTAssertEqual(searchResults2.first?.title, "Walk the dog")
        
        // Case insensitive search
        let searchResults3 = coreDataManager.searchToDos(with: "SWIFT")
        XCTAssertEqual(searchResults3.count, 1)
        XCTAssertEqual(searchResults3.first?.title, "Study Swift")
        
        // No results
        let searchResults4 = coreDataManager.searchToDos(with: "nonexistent")
        XCTAssertEqual(searchResults4.count, 0)
    }
    
    func testClearAllData() throws {
        let todo1 = ToDoEntity(title: "Todo 1", description: "Description 1")
        let todo2 = ToDoEntity(title: "Todo 2", description: "Description 2")
        
        coreDataManager.saveToDo(todo1)
        coreDataManager.saveToDo(todo2)
        XCTAssertEqual(coreDataManager.fetchAllToDos().count, 2)
        
        coreDataManager.clearAllData()
        XCTAssertEqual(coreDataManager.fetchAllToDos().count, 0)
    }
    
    func testFetchAllToDosOrdering() throws {
        // Create todos with specific dates
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        
        let oldTodo = ToDoEntity(title: "Old Todo", description: "Old", createdDate: yesterday)
        let newTodo = ToDoEntity(title: "New Todo", description: "New", createdDate: tomorrow)
        let currentTodo = ToDoEntity(title: "Current Todo", description: "Current", createdDate: now)
        
        coreDataManager.saveToDo(oldTodo)
        coreDataManager.saveToDo(newTodo)
        coreDataManager.saveToDo(currentTodo)
        
        let fetchedTodos = coreDataManager.fetchAllToDos()
        XCTAssertEqual(fetchedTodos.count, 3)
        
        // Should be ordered by creation date descending (newest first)
        XCTAssertEqual(fetchedTodos[0].title, "New Todo")
        XCTAssertEqual(fetchedTodos[1].title, "Current Todo")
        XCTAssertEqual(fetchedTodos[2].title, "Old Todo")
    }
}

