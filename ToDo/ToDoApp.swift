//
//  ToDoApp.swift
//  ToDo
//
//  Created by Aiaulym Abduohapova on 19.08.2025.
//

import SwiftUI

@main
struct ToDoApp: App {
    let persistenceController = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
