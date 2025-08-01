import SwiftUI

class AddEditToDoViewModel: AddEditToDoViewProtocol, ObservableObject {
    var presenter: (any AddEditToDoPresenterProtocol)!
    
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    func showToDo(_ todo: ToDoEntity) {
        self.title = todo.title
        self.description = todo.description
    }
    
    func showLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    func showError(_ error: String) {
        self.errorMessage = error
        self.showError = true
    }
    

}

struct AddEditToDoView: View {
    @StateObject var viewModel: AddEditToDoViewModel
    
    init(viewModel: AddEditToDoViewModel = AddEditToDoViewModel()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Simple title and description form
                    VStack(spacing: 16) {
                        // Title field
                        TextField("Заголовок", text: $viewModel.title)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        
                        // Description field
                        TextEditor(text: $viewModel.description)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .frame(minHeight: 120)
                            .scrollContentBackground(.hidden)
                        
                        // Date display
                        HStack {
                            Text(formatDate(Date()))
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .preferredColorScheme(.dark)
            .navigationTitle(viewModel.presenter?.isEditMode == true ? "Редактировать" : "Новая задача")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Назад") {
                        viewModel.presenter.cancelEditing()
                    }
                    .disabled(viewModel.isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        viewModel.presenter?.saveToDo(
                            title: viewModel.title,
                            description: viewModel.description
                        )
                    }
                    .disabled(viewModel.isLoading || viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ZStack {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                            
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                                
                                Text("Saving...")
                                    .foregroundColor(.white)
                                    .padding(.top, 8)
                            }
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(12)
                        }
                    }
                }
            )
        }
        .onAppear {
            viewModel.presenter?.viewDidLoad()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }

    }
}

#Preview {
    AddEditToDoView()
}
