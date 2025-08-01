import Foundation
import SwiftUI
import UIKit

class ToDoListRouter: ToDoListRouterProtocol {
    weak var viewController: UIViewController?
    
    static func createModule() -> UIViewController {
        let viewModel = ToDoListViewModel()
        let presenter = ToDoListPresenter()
        let interactor = ToDoListInteractor()
        let router = ToDoListRouter()
        

        viewModel.presenter = presenter
        presenter.view = viewModel
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        
        let view = ToDoListView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        router.viewController = hostingController
        
        return hostingController
    }
    
    func navigateToAddToDo() {
        let addToDoViewController: UIViewController = AddEditToDoRouter.createModule(editingToDo: nil)
        
        if let navigationController = viewController?.navigationController {
            navigationController.pushViewController(addToDoViewController, animated: true)
        } else {
            addToDoViewController.modalPresentationStyle = .formSheet
            viewController?.present(addToDoViewController, animated: true)
        }
    }
    
    func navigateToEditToDo(_ todo: ToDoEntity) {
        let editToDoViewController: UIViewController = AddEditToDoRouter.createModule(editingToDo: todo)
        
        if let navigationController = viewController?.navigationController {
            navigationController.pushViewController(editToDoViewController, animated: true)
        } else {
            editToDoViewController.modalPresentationStyle = .formSheet
            viewController?.present(editToDoViewController, animated: true)
        }
    }
}


