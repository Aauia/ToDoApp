import Foundation

class AddEditToDoPresenter: AddEditToDoPresenterProtocol {
    weak var view: (any AddEditToDoViewProtocol)?
    var interactor: (any AddEditToDoInteractorProtocol)!
    var router: (any AddEditToDoRouterProtocol)!
    
    var isEditMode: Bool {
        return interactor.editingToDo != nil
    }
    
    func viewDidLoad() {
        if let editingToDo = interactor.editingToDo {
            view?.showToDo(editingToDo)
        }
    }
    
    func saveToDo(title: String, description: String) {

        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            view?.showError("Title cannot be empty")
            return
        }
        
        view?.showLoading(true)
        interactor.saveToDo(title: title, description: description)
    }
    
    func cancelEditing() {
        router.dismissView()
    }
}

// MARK: - AddEditToDoInteractorOutputProtocol

extension AddEditToDoPresenter: AddEditToDoInteractorOutputProtocol {
    func didSaveToDo() {
        view?.showLoading(false)
        

        NotificationCenter.default.post(name: .toDoDataChanged, object: nil)
        
        router.dismissView()
    }
    
    func didFailToSaveToDo(_ error: Error) {
        view?.showLoading(false)
        view?.showError(error.localizedDescription)
    }
}
