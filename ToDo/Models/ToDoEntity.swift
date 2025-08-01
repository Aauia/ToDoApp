import Foundation

// MARK: - ToDo Entity

struct ToDoEntity: BaseEntity, Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let createdDate: Date
    let isCompleted: Bool
    let userId: Int?
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         createdDate: Date = Date(),
         isCompleted: Bool = false,
         userId: Int? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.createdDate = createdDate
        self.isCompleted = isCompleted
        self.userId = userId
    }
}

// MARK: - API Response Models

struct ToDoAPIResponse: Codable {
    let todos: [ToDoAPIModel]
    let total: Int
    let skip: Int
    let limit: Int
}

struct ToDoAPIModel: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
    
    func toEntity() -> ToDoEntity {
        return ToDoEntity(
            id: "\(id)",
            title: todo,
            description: todo,
            createdDate: Date(),
            isCompleted: completed,
            userId: userId
        )
    }
}

