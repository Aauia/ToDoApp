import Foundation
import SwiftUI

// MARK: - ToDo List VIPER Protocols

protocol ToDoListViewProtocol: BaseView {
    var presenter: (any ToDoListPresenterProtocol)! { get set }
    func showToDos(_ todos: [ToDoEntity])
    func showLoading(_ isLoading: Bool)
    func showError(_ error: String)
    func showSearchResults(_ todos: [ToDoEntity])
}

protocol ToDoListPresenterProtocol: BasePresenter {
    var view: (any ToDoListViewProtocol)? { get set }
    var interactor: (any ToDoListInteractorProtocol)! { get set }
    var router: (any ToDoListRouterProtocol)! { get set }
    
    func viewDidLoad()
    func refreshToDos()
    func refreshLocalToDos()
    func syncWithAPI()
    func searchToDos(with text: String)
    func toggleToDoCompletion(_ todo: ToDoEntity)
    func deleteToDo(_ todo: ToDoEntity)
    func addNewToDo()
    func editToDo(_ todo: ToDoEntity)
}

protocol ToDoListInteractorProtocol: BaseInteractor {
    var presenter: (any ToDoListInteractorOutputProtocol)? { get set }
    
    func fetchToDosFromAPI()
    func fetchLocalToDos()
    func searchToDos(with text: String)
    func toggleToDoCompletion(_ todo: ToDoEntity)
    func deleteToDo(_ todo: ToDoEntity)
}

protocol ToDoListInteractorOutputProtocol: AnyObject {
    func didFetchToDos(_ todos: [ToDoEntity])
    func didFailToFetchToDos(_ error: Error)
    func didUpdateToDo()
    func didDeleteToDo()
    func didSearchToDos(_ todos: [ToDoEntity])
}

protocol ToDoListRouterProtocol: BaseRouter {
    var viewController: UIViewController? { get set }
    
    static func createModule() -> UIViewController
    func navigateToAddToDo()
    func navigateToEditToDo(_ todo: ToDoEntity)
}
