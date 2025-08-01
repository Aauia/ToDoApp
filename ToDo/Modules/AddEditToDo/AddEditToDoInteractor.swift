//
//  AddEditToDoInteractor.swift
//  ToDo
//
//  Created by Aiaulym Abduohapova on 19.08.2025.
//

import Foundation

class AddEditToDoInteractor: AddEditToDoInteractorProtocol {
    weak var presenter: (any AddEditToDoInteractorOutputProtocol)?
    var editingToDo: ToDoEntity?
    
    private let backgroundService: BackgroundOperationService
    
    init(editingToDo: ToDoEntity? = nil,
         backgroundService: BackgroundOperationService = BackgroundOperationService.shared) {
        self.editingToDo = editingToDo
        self.backgroundService = backgroundService
    }
    
    func saveToDo(title: String, description: String) {
        let todo: ToDoEntity
        
        if let existingToDo = editingToDo {

            todo = ToDoEntity(
                id: existingToDo.id,
                title: title,
                description: description,
                createdDate: existingToDo.createdDate,
                isCompleted: existingToDo.isCompleted,
                userId: existingToDo.userId
            )
            
            backgroundService.updateToDo(todo) { [weak self] result in
                switch result {
                case .success:
                    self?.presenter?.didSaveToDo()
                case .failure(let error):
                    self?.presenter?.didFailToSaveToDo(error)
                }
            }
        } else {

            todo = ToDoEntity(
                title: title,
                description: description
            )
            
            backgroundService.saveToDo(todo) { [weak self] result in
                switch result {
                case .success:
                    self?.presenter?.didSaveToDo()
                case .failure(let error):
                    self?.presenter?.didFailToSaveToDo(error)
                }
            }
        }
    }
}
