import XCTest
@testable import ToDo

final class ToDoListPresenterTests: XCTestCase {
    
    var presenter: ToDoListPresenter!
    var mockView: MockToDoListViewModel!
    var mockInteractor: MockToDoListInteractor!
    var mockRouter: MockToDoListRouter!
    
    override func setUpWithError() throws {
        presenter = ToDoListPresenter()
        mockView = MockToDoListViewModel()
        mockInteractor = MockToDoListInteractor()
        mockRouter = MockToDoListRouter()
        
        presenter.view = mockView
        presenter.interactor = mockInteractor
        presenter.router = mockRouter
        mockInteractor.presenter = presenter
    }
    
    override func tearDownWithError() throws {
        presenter = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
    }
    
    func testViewDidLoad() throws {
        presenter.viewDidLoad()
        
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertTrue(mockInteractor.fetchLocalToDosCalled)
        XCTAssertTrue(mockInteractor.fetchToDosFromAPICalled)
    }
    
    func testRefreshToDos() throws {
        presenter.refreshToDos()
        
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertTrue(mockInteractor.fetchToDosFromAPICalled)
    }
    
    func testSearchToDos() throws {
        presenter.searchToDos(with: "test")
        XCTAssertTrue(mockInteractor.searchToDosCalled)
        
        presenter.searchToDos(with: "")
        XCTAssertTrue(mockInteractor.fetchLocalToDosCalled)
    }
    
    func testDidFetchToDos() throws {
        let testTodos = [
            ToDoEntity(title: "Test 1", description: "Description 1"),
            ToDoEntity(title: "Test 2", description: "Description 2")
        ]
        
        presenter.didFetchToDos(testTodos)
        
        XCTAssertTrue(mockView.showToDosCalled)
        XCTAssertEqual(mockView.lastTodos?.count, 2)
        XCTAssertFalse(mockView.lastLoadingState)
    }
    
    func testToggleToDoCompletion() throws {
        let testTodo = ToDoEntity(title: "Test", description: "Description")
        
        presenter.toggleToDoCompletion(testTodo)
        
        XCTAssertTrue(mockInteractor.toggleToDoCompletionCalled)
    }
    
    func testDeleteToDo() throws {
        let testTodo = ToDoEntity(title: "Test", description: "Description")
        
        presenter.deleteToDo(testTodo)
        
        XCTAssertTrue(mockInteractor.deleteToDosCalled)
    }
    
    func testAddNewToDo() throws {
        presenter.addNewToDo()
        
        XCTAssertTrue(mockRouter.navigateToAddToDoCalled)
    }
    
    func testEditToDo() throws {
        let testTodo = ToDoEntity(title: "Test", description: "Description")
        
        presenter.editToDo(testTodo)
        
        XCTAssertTrue(mockRouter.navigateToEditToDoCalled)
    }
    
    func testDidUpdateToDo() throws {
        presenter.didUpdateToDo()
        
        XCTAssertTrue(mockInteractor.fetchLocalToDosCalled)
    }
    
    func testDidDeleteToDo() throws {
        presenter.didDeleteToDo()
        
        XCTAssertTrue(mockInteractor.fetchLocalToDosCalled)
    }
    
    func testDidSearchToDos() throws {
        let testTodos = [
            ToDoEntity(title: "Search Result", description: "Description")
        ]
        
        presenter.didSearchToDos(testTodos)
        
        XCTAssertTrue(mockView.showSearchResultsCalled)
        XCTAssertEqual(mockView.lastTodos?.count, 1)
    }
    
    func testDidFailToFetchToDos() throws {
        let error = NSError(domain: "Test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        presenter.didFailToFetchToDos(error)
        
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.lastError, "Test error")
        XCTAssertFalse(mockView.lastLoadingState)
    }
}

// MARK: - Mock Classes

class MockToDoListViewModel: ToDoListViewProtocol {
    var presenter: (any ToDoListPresenterProtocol)!
    
    var showToDosCalled = false
    var showLoadingCalled = false
    var showErrorCalled = false
    var showSearchResultsCalled = false
    
    var lastTodos: [ToDoEntity]?
    var lastLoadingState = false
    var lastError: String?
    
    func showToDos(_ todos: [ToDoEntity]) {
        showToDosCalled = true
        lastTodos = todos
    }
    
    func showLoading(_ isLoading: Bool) {
        showLoadingCalled = true
        lastLoadingState = isLoading
    }
    
    func showError(_ error: String) {
        showErrorCalled = true
        lastError = error
    }
    
    func showSearchResults(_ todos: [ToDoEntity]) {
        showSearchResultsCalled = true
        lastTodos = todos
    }
}

class MockToDoListInteractor: ToDoListInteractorProtocol {
    var presenter: (any ToDoListInteractorOutputProtocol)?
    
    var fetchToDosFromAPICalled = false
    var fetchLocalToDosCalled = false
    var searchToDosCalled = false
    var toggleToDoCompletionCalled = false
    var deleteToDosCalled = false
    
    func fetchToDosFromAPI() {
        fetchToDosFromAPICalled = true
    }
    
    func fetchLocalToDos() {
        fetchLocalToDosCalled = true
    }
    
    func searchToDos(with text: String) {
        searchToDosCalled = true
    }
    
    func toggleToDoCompletion(_ todo: ToDoEntity) {
        toggleToDoCompletionCalled = true
    }
    
    func deleteToDo(_ todo: ToDoEntity) {
        deleteToDosCalled = true
    }
}

class MockToDoListRouter: ToDoListRouterProtocol {
    var viewController: UIViewController?
    
    var navigateToAddToDoCalled = false
    var navigateToEditToDoCalled = false
    
    static func createModule() -> UIViewController {
        return UIViewController()
    }
    
    func navigateToAddToDo() {
        navigateToAddToDoCalled = true
    }
    
    func navigateToEditToDo(_ todo: ToDoEntity) {
        navigateToEditToDoCalled = true
    }
}
