//
//  ToDoListInteractor.swift
//  ToDo
//
//  Created by Aiaulym Abduohapova on 19.08.2025.
//

import Foundation
import Combine

class ToDoListInteractor: ToDoListInteractorProtocol {
    weak var presenter: (any ToDoListInteractorOutputProtocol)?
    
    private let networkService: any NetworkServiceProtocol
    private let backgroundService: BackgroundOperationService
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: any NetworkServiceProtocol = NetworkService.shared,
         backgroundService: BackgroundOperationService = BackgroundOperationService.shared) {
        self.networkService = networkService
        self.backgroundService = backgroundService
    }
    
    func fetchToDosFromAPI() {
        networkService.fetchToDos()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.presenter?.didFailToFetchToDos(error)
                    }
                },
                receiveValue: { [weak self] todos in

                    self?.saveToDosToLocal(todos)
                    self?.presenter?.didFetchToDos(todos)
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchLocalToDos() {
        backgroundService.fetchToDos { [weak self] result in
            switch result {
            case .success(let todos):
                self?.presenter?.didFetchToDos(todos)
            case .failure(let error):
                self?.presenter?.didFailToFetchToDos(error)
            }
        }
    }
    
    func searchToDos(with text: String) {
        backgroundService.searchToDos(with: text) { [weak self] result in
            switch result {
            case .success(let todos):
                self?.presenter?.didSearchToDos(todos)
            case .failure(let error):
                self?.presenter?.didFailToFetchToDos(error)
            }
        }
    }
    
    func toggleToDoCompletion(_ todo: ToDoEntity) {
        let updatedToDo = ToDoEntity(
            id: todo.id,
            title: todo.title,
            description: todo.description,
            createdDate: todo.createdDate,
            isCompleted: !todo.isCompleted,
            userId: todo.userId
        )
        
        backgroundService.updateToDo(updatedToDo) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.didUpdateToDo()
            case .failure(let error):
                self?.presenter?.didFailToFetchToDos(error)
            }
        }
    }
    
    func deleteToDo(_ todo: ToDoEntity) {
        backgroundService.deleteToDo(withId: todo.id) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.didDeleteToDo()
            case .failure(let error):
                self?.presenter?.didFailToFetchToDos(error)
            }
        }
    }
    
    private func saveToDosToLocal(_ todos: [ToDoEntity]) {

        DispatchQueue.global(qos: .background).async {
            let existingTodos = CoreDataManager.shared.fetchAllToDos()
            let existingIds = Set(existingTodos.map { $0.id })
            

            todos.forEach { todo in
                do {
                    try CoreDataManager.shared.saveNewToDoIfNotExists(todo)
                } catch {
                    // Handle error silently or log appropriately
                }
            }
        }
    }
}
