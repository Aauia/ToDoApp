//
//  ToDoListPresenter.swift
//  ToDo
//
//  Created by Aiaulym Abduohapova on 19.08.2025.
//

import Foundation

class ToDoListPresenter: ToDoListPresenterProtocol {
    weak var view: (any ToDoListViewProtocol)?
    var interactor: (any ToDoListInteractorProtocol)!
    var router: (any ToDoListRouterProtocol)!
    
    private var isFirstLoad = true
    
    func viewDidLoad() {
        view?.showLoading(true)
        

        interactor.fetchLocalToDos()
        

        if isFirstLoad {
            interactor.fetchToDosFromAPI()
            isFirstLoad = false
        }
    }
    
    func refreshToDos() {
        view?.showLoading(true)

        interactor.fetchLocalToDos()
    }
    
    func refreshLocalToDos() {
        interactor.fetchLocalToDos()
    }
    
    func syncWithAPI() {
        view?.showLoading(true)
        interactor.fetchToDosFromAPI()
    }
    
    func searchToDos(with text: String) {
        if text.isEmpty {
            interactor.fetchLocalToDos()
        } else {
            interactor.searchToDos(with: text)
        }
    }
    
    func toggleToDoCompletion(_ todo: ToDoEntity) {
        interactor.toggleToDoCompletion(todo)
    }
    
    func deleteToDo(_ todo: ToDoEntity) {
        interactor.deleteToDo(todo)
    }
    
    func addNewToDo() {
        router.navigateToAddToDo()
    }
    
    func editToDo(_ todo: ToDoEntity) {
        router.navigateToEditToDo(todo)
    }
}

// MARK: - ToDoListInteractorOutputProtocol

extension ToDoListPresenter: ToDoListInteractorOutputProtocol {
    func didFetchToDos(_ todos: [ToDoEntity]) {
        view?.showLoading(false)
        view?.showToDos(todos)
    }
    
    func didFailToFetchToDos(_ error: Error) {
        view?.showLoading(false)
        view?.showError(error.localizedDescription)
    }
    
    func didUpdateToDo() {
        NotificationCenter.default.post(name: .toDoDataChanged, object: nil)
        interactor.fetchLocalToDos()
    }
    
    func didDeleteToDo() {
        NotificationCenter.default.post(name: .toDoDataChanged, object: nil)
        interactor.fetchLocalToDos()
    }
    
    func didSearchToDos(_ todos: [ToDoEntity]) {
        view?.showSearchResults(todos)
    }
}
