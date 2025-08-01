//
//  CoreDataManager.swift
//  ToDo
//
//  Created by Aiaulym Abduohapova on 19.08.2025.
//

import Foundation
import CoreData
import Combine

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoDataModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Handle error appropriately
            }
        }
    }
    
    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    // MARK: - ToDo Operations
    
    func saveToDo(_ entity: ToDoEntity) throws {
        try context.performAndWait {
            // Check if item already exists
            let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", entity.id)
            
            do {
                let existingItems = try context.fetch(request)
                if let existingItem = existingItems.first {

                    existingItem.title = entity.title
                    existingItem.taskDescription = entity.description
                    existingItem.createdDate = entity.createdDate
                    existingItem.isCompleted = entity.isCompleted
                    existingItem.userId = Int32(entity.userId ?? 0)
                } else {

                    let todoItem = ToDoItem(context: context)
                    todoItem.id = entity.id
                    todoItem.title = entity.title
                    todoItem.taskDescription = entity.description
                    todoItem.createdDate = entity.createdDate
                    todoItem.isCompleted = entity.isCompleted
                    todoItem.userId = Int32(entity.userId ?? 0)
                }
                
                try saveContext()
            } catch {
                throw error
            }
        }
    }
    
    func saveNewToDoIfNotExists(_ entity: ToDoEntity) throws {
        try context.performAndWait {
            // Check if item already exists
            let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", entity.id)
            
            do {
                let existingItems = try context.fetch(request)
                if existingItems.isEmpty {

                    let todoItem = ToDoItem(context: context)
                    todoItem.id = entity.id
                    todoItem.title = entity.title
                    todoItem.taskDescription = entity.description
                    todoItem.createdDate = entity.createdDate
                    todoItem.isCompleted = entity.isCompleted
                    todoItem.userId = Int32(entity.userId ?? 0)
                    
                    try saveContext()
                }
            } catch {
                throw error
            }
        }
    }
    
    func updateToDo(_ entity: ToDoEntity) throws {
        try context.performAndWait {
            let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", entity.id)
            
            do {
                let results = try context.fetch(request)
                if let todoItem = results.first {
                    todoItem.title = entity.title
                    todoItem.taskDescription = entity.description
                    todoItem.isCompleted = entity.isCompleted
                    try saveContext()
                }
            } catch {
                throw error
            }
        }
    }
    
    func deleteToDo(withId id: String) {
        context.performAndWait {
            let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let results = try context.fetch(request)
                if let todoItem = results.first {
                    context.delete(todoItem)
                    save()
                }
            } catch {
                // Handle error appropriately
            }
        }
    }
    
    func fetchAllToDos() -> [ToDoEntity] {
        var entities: [ToDoEntity] = []
        context.performAndWait {
            let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ToDoItem.createdDate, ascending: false)]
            
            do {
                let results = try context.fetch(request)
                entities = results.map { $0.toEntity() }
            } catch {
                entities = []
            }
        }
        return entities
    }
    
    func searchToDos(with searchText: String) -> [ToDoEntity] {
        var entities: [ToDoEntity] = []
        context.performAndWait {
            let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR taskDescription CONTAINS[cd] %@", searchText, searchText)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ToDoItem.createdDate, ascending: false)]
            
            do {
                let results = try context.fetch(request)
                entities = results.map { $0.toEntity() }
            } catch {
                entities = []
            }
        }
        return entities
    }
    
    func clearAllData() {
        context.performAndWait {
            let request: NSFetchRequest<NSFetchRequestResult> = ToDoItem.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(deleteRequest)
                save()
            } catch {
                // Handle error appropriately
            }
        }
    }
}

// MARK: - ToDoItem Extension

extension ToDoItem {
    func toEntity() -> ToDoEntity {
        return ToDoEntity(
            id: self.id ?? UUID().uuidString,
            title: self.title ?? "",
            description: self.taskDescription ?? "",
            createdDate: self.createdDate ?? Date(),
            isCompleted: self.isCompleted,
            userId: self.userId == 0 ? nil : Int(self.userId)
        )
    }
}
