import Foundation
import SwiftUI
import UIKit



protocol BaseView: AnyObject {

}

protocol BasePresenter: AnyObject {

}

protocol BaseInteractor: AnyObject {

}

protocol BaseRouter: AnyObject {

}



protocol BaseEntity {
    var id: String { get }
}
