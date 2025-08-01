//
//  ContentView.swift
//  ToDo
//
//  Created by Aiaulym Abduohapova on 19.08.2025.
//

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        ToDoListWrapperView()
    }
}

struct ToDoListWrapperView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ToDoListRouter.createModule()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    ContentView()
}
