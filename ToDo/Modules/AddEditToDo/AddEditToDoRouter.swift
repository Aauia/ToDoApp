import Foundation
import SwiftUI
import UIKit

class AddEditToDoRouter: AddEditToDoRouterProtocol {
    weak var viewController: UIViewController?
    
    static func createModule(editingToDo: ToDoEntity?) -> UIViewController {
        let viewModel = AddEditToDoViewModel()
        let presenter = AddEditToDoPresenter()
        let interactor = AddEditToDoInteractor(editingToDo: editingToDo)
        let router = AddEditToDoRouter()
        
        viewModel.presenter = presenter
        presenter.view = viewModel
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        
        let view = AddEditToDoView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        router.viewController = hostingController
        
        let navigationController = UINavigationController(rootViewController: hostingController)
        
        return navigationController
    }
    
    func dismissView() {
        if let navigationController = viewController?.navigationController,
           navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            viewController?.dismiss(animated: true)
        }
    }
}


