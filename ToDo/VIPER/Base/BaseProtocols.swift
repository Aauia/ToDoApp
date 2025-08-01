//
//  BaseProtocols.swift
//  ToDo
//
//  Created by Aiaulym Abduohapova on 19.08.2025.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Base VIPER Protocols

protocol BaseView: AnyObject {
    // Remove associated types to avoid conformance issues
}

protocol BasePresenter: AnyObject {
    // Remove associated types to avoid conformance issues
}

protocol BaseInteractor: AnyObject {
    // Remove associated types to avoid conformance issues
}

protocol BaseRouter: AnyObject {
    // Base router protocol for VIPER architecture
}

// MARK: - Entity Protocol

protocol BaseEntity {
    var id: String { get }
}
