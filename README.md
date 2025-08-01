# ToDo List App

A comprehensive ToDo List application built with SwiftUI using VIPER architecture pattern.

## Features

- ✅ **CRUD Operations**: Create, Read, Update, Delete todos
- 🔍 **Search Functionality**: Search through todos by title and description
- 💾 **Core Data Integration**: Persistent local storage
- 🌐 **API Integration**: Fetches initial data from DummyJSON API
- 🧵 **Background Processing**: All operations handled in background threads
- 🏗️ **VIPER Architecture**: Clean, testable, and maintainable code structure
- ✅ **Unit Tests**: Comprehensive test coverage for core components
- 🎨 **Modern UI**: Beautiful SwiftUI interface with pull-to-refresh

## Architecture

This app follows the **VIPER** (View, Interactor, Presenter, Entity, Router) architecture pattern:

- **View**: SwiftUI views that handle user interface
- **Interactor**: Business logic and data operations
- **Presenter**: Mediates between View and Interactor
- **Entity**: Data models
- **Router**: Navigation logic

## Project Structure

```
ToDo/
├── VIPER/Base/           # Base VIPER protocols
├── Models/               # Data entities
├── Services/             # Network and background services
├── CoreData/             # Core Data stack and models
├── Modules/
│   ├── ToDoList/         # Main todo list module
│   └── AddEditToDo/      # Add/Edit todo module
└── ToDoTests/            # Unit tests
```

## Requirements Met

1. ✅ **Task List Management**: Full CRUD operations
2. ✅ **API Integration**: Loads from https://dummyjson.com/todos
3. ✅ **Multithreading**: GCD and NSOperation for background processing
4. ✅ **Core Data**: Persistent storage with proper data restoration
5. ✅ **Version Control**: Git-ready project structure
6. ✅ **Unit Tests**: Comprehensive test coverage
7. ✅ **Xcode 15 Compatibility**: Modern SwiftUI and iOS 18.5 target
8. ✅ **VIPER Architecture**: Clean separation of concerns

## Technical Implementation

### Background Processing
- **GCD**: Used for simple async operations
- **NSOperation**: Used for complex, cancellable operations
- **Combine**: Reactive programming for network requests

### Data Layer
- **Core Data**: Local persistence with automatic merging
- **Network Service**: RESTful API integration with error handling
- **Background Service**: Manages all async operations

### Testing
- **Unit Tests**: Core business logic testing
- **Mock Objects**: Isolated testing of VIPER components
- **Core Data Tests**: Persistence layer validation

## Getting Started

1. Open `ToDo.xcodeproj` in Xcode 15+
2. Build and run the project
3. The app will automatically fetch initial todos from the API
4. Start adding, editing, and managing your todos!

## API Integration

The app integrates with the DummyJSON API:
- **Endpoint**: https://dummyjson.com/todos
- **Initial Load**: Fetches todos on first app launch
- **Offline Support**: Works entirely offline after initial load

## Future Enhancements

- Push notifications for todo reminders
- Categories and tags for todos
- Due dates and priority levels
- Sharing and collaboration features

