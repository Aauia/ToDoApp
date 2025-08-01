//
//  NetworkService.swift
//  ToDo
//
//  Created by Aiaulym Abduohapova on 19.08.2025.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func fetchToDos() -> AnyPublisher<[ToDoEntity], Error>
}

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    private let session = URLSession.shared
    private let baseURL = "https://dummyjson.com"
    
    private init() {}
    
    func fetchToDos() -> AnyPublisher<[ToDoEntity], Error> {
        guard let url = URL(string: "\(baseURL)/todos") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ToDoAPIResponse.self, decoder: JSONDecoder())
            .map { response in
                response.todos.map { $0.toEntity() }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Network Error

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

