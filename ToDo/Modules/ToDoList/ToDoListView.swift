import SwiftUI

class ToDoListViewModel: ToDoListViewProtocol, ObservableObject {
    var presenter: (any ToDoListPresenterProtocol)!
    
    @Published var todos: [ToDoEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var searchText: String = ""
    @Published var showError: Bool = false
    
    func showToDos(_ todos: [ToDoEntity]) {
        self.todos = todos
    }
    
    func showLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    func showError(_ error: String) {
        self.errorMessage = error
        self.showError = true
    }
    
    func showSearchResults(_ todos: [ToDoEntity]) {
        self.todos = todos
    }
}

struct ToDoListView: View {
    @StateObject var viewModel: ToDoListViewModel
    
    init(viewModel: ToDoListViewModel = ToDoListViewModel()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchText) { searchText in
                    viewModel.presenter.searchToDos(with: searchText)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if viewModel.isLoading && viewModel.todos.isEmpty {
                    // Loading State
                    VStack {
                        Spacer()
                        ProgressView("Loading ToDos...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(1.2)
                        Spacer()
                    }
                } else if viewModel.todos.isEmpty && !viewModel.searchText.isEmpty {
                    // Empty Search Results
                    VStack {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Ничего не найдено")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding(.top)
                        Text("Попробуйте другие ключевые слова")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .background(Color.black)
                } else if viewModel.todos.isEmpty {
                    // Empty State
                    VStack {
                        Spacer()
                        Image(systemName: "checklist")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Пока нет задач")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding(.top)
                        Text("Нажмите + чтобы добавить первую задачу")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .background(Color.black)
                } else {

                    List {
                        ForEach(viewModel.todos) { todo in
                            ToDoRowView(todo: todo) { action in
                                switch action {
                                case .toggle:
                                    viewModel.presenter.toggleToDoCompletion(todo)
                                case .edit:
                                    viewModel.presenter.editToDo(todo)
                                case .delete:
                                    viewModel.presenter.deleteToDo(todo)
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.black)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color.black)
                    .refreshable {
                        viewModel.presenter.refreshToDos()
                    }
                }
            }
            .background(Color.black)
            .navigationTitle("Задачи")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(viewModel.todos.count) Задач")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    }
                }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.presenter.addNewToDo()
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .onAppear {
            if viewModel.presenter == nil {
                return
            }
            viewModel.presenter.viewDidLoad()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in

            viewModel.presenter?.refreshToDos()
        }
        .onReceive(NotificationCenter.default.publisher(for: .toDoDataChanged)) { _ in

            viewModel.presenter?.refreshLocalToDos()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String
    let onSearchTextChanged: (String) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .onChange(of: text) {
                    let currentText = text
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if currentText == text {
                            onSearchTextChanged(currentText)
                        }
                    }
                }
            
            if !text.isEmpty {
                Button("Clear") {
                    text = ""
                    onSearchTextChanged("")
                }
                .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - ToDo Row View

enum ToDoRowAction {
    case toggle
    case edit
    case delete
}

struct ToDoRowView: View {
    let todo: ToDoEntity
    let onAction: (ToDoRowAction) -> Void
    @State private var showDetailView = false
    
    var body: some View {
        HStack(spacing: 12) {

            Button(action: {
                onAction(.toggle)
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(todo.isCompleted ? .yellow : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(todo.title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(todo.isCompleted ? .secondary : .primary)
                        .strikethrough(todo.isCompleted)
                        .lineLimit(1)
                    
                    Text(formatDate(todo.createdDate))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showDetailView = true
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.clear)
        .sheet(isPresented: $showDetailView) {
            ToDoDetailView(todo: todo) { action in
                if action == .edit {
                    showDetailView = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onAction(action)
                    }
                } else {
                    showDetailView = false
                    onAction(action)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}

// MARK: - ToDo Detail View

struct ToDoDetailView: View {
    let todo: ToDoEntity
    let onAction: (ToDoRowAction) -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                

                VStack(spacing: 12) {
                    Text(todo.title)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(todo.description)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(formatDate(todo.createdDate))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal)
                
                // Action buttons
                VStack(spacing: 0) {
                    Button(action: {
                        onAction(.edit)
                    }) {
                        HStack {
                            Text("Редактировать")
                                .font(.system(size: 17))
                                .foregroundColor(.yellow)
                            Spacer()
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 17))
                                .foregroundColor(.yellow)
                        }
                        .padding()
                        .background(Color(.systemGray5))
                    }
                    
                    Divider()
                        .background(Color(.systemGray4))
                    
                    Button(action: {
                        onAction(.delete)
                    }) {
                        HStack {
                            Text("Удалить")
                                .font(.system(size: 17))
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "trash")
                                .font(.system(size: 17))
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color(.systemGray5))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}

#Preview {
    ToDoListView()
}
