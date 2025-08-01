import XCTest
@testable import ToDo

final class AddEditToDoPresenterTests: XCTestCase {
    
    var presenter: AddEditToDoPresenter!
    var mockView: MockAddEditToDoViewModel!
    var mockInteractor: MockAddEditToDoInteractor!
    var mockRouter: MockAddEditToDoRouter!
    
    override func setUpWithError() throws {
        presenter = AddEditToDoPresenter()
        mockView = MockAddEditToDoViewModel()
        mockInteractor = MockAddEditToDoInteractor()
        mockRouter = MockAddEditToDoRouter()
        
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
    
    func testViewDidLoadWithNewToDo() throws {
        mockInteractor.editingToDo = nil
        
        presenter.viewDidLoad()
        
        XCTAssertFalse(mockView.showToDoCalled)
        XCTAssertFalse(presenter.isEditMode)
    }
    
    func testViewDidLoadWithExistingToDo() throws {
        let testTodo = ToDoEntity(title: "Test", description: "Test Description")
        mockInteractor.editingToDo = testTodo
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(mockView.showToDoCalled)
        XCTAssertTrue(presenter.isEditMode)
    }
    
    func testSaveToDoWithValidInput() throws {
        presenter.saveToDo(title: "Valid Title", description: "Valid Description")
        
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertTrue(mockInteractor.saveToDoCalled)
    }
    
    func testSaveToDoWithEmptyTitle() throws {
        presenter.saveToDo(title: "", description: "Valid Description")
        
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.lastError, "Title cannot be empty")
        XCTAssertFalse(mockInteractor.saveToDoCalled)
    }
    
    func testSaveToDoWithWhitespaceTitle() throws {
        presenter.saveToDo(title: "   ", description: "Valid Description")
        
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.lastError, "Title cannot be empty")
        XCTAssertFalse(mockInteractor.saveToDoCalled)
    }
    
    func testCancelEditing() throws {
        presenter.cancelEditing()
        
        XCTAssertTrue(mockRouter.dismissViewCalled)
    }
    
    func testDidSaveToDo() throws {
        presenter.didSaveToDo()
        
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertFalse(mockView.lastLoadingState)
        XCTAssertTrue(mockRouter.dismissViewCalled)
    }
    
    func testDidFailToSaveToDo() throws {
        let error = NSError(domain: "Test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Save failed"])
        
        presenter.didFailToSaveToDo(error)
        
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertFalse(mockView.lastLoadingState)
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.lastError, "Save failed")
    }
}

// MARK: - Mock Classes

class MockAddEditToDoViewModel: AddEditToDoViewProtocol {
    var presenter: (any AddEditToDoPresenterProtocol)!
    
    var showToDoCalled = false
    var showLoadingCalled = false
    var showErrorCalled = false
    
    var lastTodo: ToDoEntity?
    var lastLoadingState = false
    var lastError: String?
    
    func showToDo(_ todo: ToDoEntity) {
        showToDoCalled = true
        lastTodo = todo
    }
    
    func showLoading(_ isLoading: Bool) {
        showLoadingCalled = true
        lastLoadingState = isLoading
    }
    
    func showError(_ error: String) {
        showErrorCalled = true
        lastError = error
    }
}

class MockAddEditToDoInteractor: AddEditToDoInteractorProtocol {
    var presenter: (any AddEditToDoInteractorOutputProtocol)?
    var editingToDo: ToDoEntity?
    
    var saveToDoCalled = false
    
    func saveToDo(title: String, description: String) {
        saveToDoCalled = true
    }
}

class MockAddEditToDoRouter: AddEditToDoRouterProtocol {
    var viewController: UIViewController?
    
    var dismissViewCalled = false
    
    static func createModule(editingToDo: ToDoEntity?) -> UIViewController {
        return UIViewController()
    }
    
    func dismissView() {
        dismissViewCalled = true
    }
}
