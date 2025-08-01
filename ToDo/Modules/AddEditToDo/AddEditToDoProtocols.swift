//
//  AddEditToDoProtocols.swift
//  ToDo
//
//  Created by Aiaulym Abduohapova on 19.08.2025.
//

import Foundation
import SwiftUI

// MARK: - Add/Edit ToDo VIPER Protocols

protocol AddEditToDoViewProtocol: BaseView {
    var presenter: (any AddEditToDoPresenterProtocol)! { get set }
    func showToDo(_ todo: ToDoEntity)
    func showLoading(_ isLoading: Bool)
    func showError(_ error: String)
}

protocol AddEditToDoPresenterProtocol: BasePresenter {
    var view: (any AddEditToDoViewProtocol)? { get set }
    var interactor: (any AddEditToDoInteractorProtocol)! { get set }
    var router: (any AddEditToDoRouterProtocol)! { get set }
    
    var isEditMode: Bool { get }
    
    func viewDidLoad()
    func saveToDo(title: String, description: String)
    func cancelEditing()
}

protocol AddEditToDoInteractorProtocol: BaseInteractor {
    var presenter: (any AddEditToDoInteractorOutputProtocol)? { get set }
    var editingToDo: ToDoEntity? { get set }
    
    func saveToDo(title: String, description: String)
}

protocol AddEditToDoInteractorOutputProtocol: AnyObject {
    func didSaveToDo()
    func didFailToSaveToDo(_ error: Error)
}

protocol AddEditToDoRouterProtocol: BaseRouter {
    var viewController: UIViewController? { get set }
    
    static func createModule(editingToDo: ToDoEntity?) -> UIViewController
    func dismissView()
}
