//
//  ContentView.swift
//  TCA_TODO_TOUR
//
//  Created by paige shin on 2022/11/09.
//

import SwiftUI
import ComposableArchitecture
import Combine

struct Todo: Equatable, Identifiable {
    var id: UUID
    var description = ""
    var isComplete = false
}

enum TodoAction: Equatable {
    case checkboxTapped
    case textFieldChanged(String)
}

struct TodoEnvironment {
    
}

let todoReducer = AnyReducer<Todo, TodoAction, TodoEnvironment> { state, action, environment in
    switch action {
    case .checkboxTapped:
        state.isComplete.toggle()
        return .none
    case .textFieldChanged(let text):
        state.description = text
        return .none
    }
}

struct AppState: Equatable {
    var todos: [Todo]
}

enum AppAction: Equatable {
    case addButtonTapped
    case todo(index: Int, action: TodoAction)
    case todoDelayCompleted
//    case todoCheckboxTapped(index: Int)
//    case todoTextFieldChanged(index: Int, text: String)
}

struct AppEnvironment {
    // Scheduler is coming from Combine and Composable Architecture
    // This API integrates DispatchQueue.main.schedule
    // Improved Testability
    /*
    var mainQueue: AnyScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>\
     */
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
}

// Combined Reducer
let appReducer: AnyReducer<AppState, AppAction, AppEnvironment> = AnyReducer.combine(
    todoReducer.forEach(
        state: \AppState.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnvironment() }),
    AnyReducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: environment.uuid()), at: 0)
            return .none
        case .todo(index: _, action: .checkboxTapped):
            
            struct CancelDelayId: Hashable {
                
            }
            
            /*
            return .concatenate(
                Effect.cancel(id: "completion-effect"),
                Effect(value: AppAction.todoDelayCompleted)
                    .delay(for: 1, scheduler: DispatchQueue.main)
                    .eraseToEffect()
                    .cancellable(id: "completion-effect") // Cancel Execution
            )
             */
            
            /*
            return Effect(value: AppAction.todoDelayCompleted)
                .delay(for: 1, scheduler: DispatchQueue.main)
                .eraseToEffect()
                .cancellable(id: "completion-effect", cancelInFlight: true) // if any actions for `todoDelayCompleted` exists, cancel previous operation
            */
            
            
            return Effect(value: AppAction.todoDelayCompleted)
                .delay(for: 1, scheduler: environment.mainQueue)
                .eraseToEffect()
                .cancellable(id: CancelDelayId(), cancelInFlight: true) // if any actions for `todoDelayCompleted` exists, cancel previous operation
             
            
            /*
            return Effect(value: AppAction.todoDelayCompleted)
                .debounce(id: CancelDelayId(), for: 1, scheduler: DispatchQueue.main)
//                .delay(for: 1, scheduler: DispatchQueue.main)
//                .eraseToEffect()
//                .cancellable(id: CancelDelayId(), cancelInFlight: true) // if any actions for `todoDelayCompleted` exists, cancel previous operation
             */
        case .todoDelayCompleted:
            state.todos = state.todos
                .enumerated()
                .sorted { lhs, rhs in
                    (!lhs.element.isComplete && rhs.element.isComplete) ||
                    lhs.offset < rhs.offset
                }
//                .map { $0.element }
                .map(\.element)
            return .none
        case .todo(index: let index, action: let action):
            // You can add new features here
            return .none
        }
    }
)
.debug()


// Higher Order Reducer For List
/*
let appReducer: AnyReducer<AppState, AppAction, AppEnvironment> = todoReducer.forEach(
    state: \AppState.todos,
    action: /AppAction.todo(index:action:),
    environment: { _ in TodoEnvironment()}
)
.debug()
 */

// Vanilla Reducer
/*
let appReducer = AnyReducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .todoCheckboxTapped(index: let index):
        state.todos[index].isComplete.toggle()
        return .none
    case .todoTextFieldChanged(index: let index, text: let text):
        state.todos[index].description = text
        return .none
    }
}
 for debug
.debug() // this prints debug information
*/
 
struct ContentView: View {
    
    let store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                List {
                    // zip(viewStore.todos.indices, viewStore.todos)
                    // Array(viewStore.state.todos.enumerated()), \.element.id

                    /*
                    ForEachStore(
                        self.store.scope(
                            state: { $0.todos },
                            action: { AppAction.todo(index: $0, action: $1) }
                        )
                    ) { todoStore in
                        TodoView(store: todoStore)
                    }
                     */
                    
                    ForEachStore(
                        self.store.scope(
                            state: \.todos ,
                            action: AppAction.todo(index:action:)
                        ),
                        content: TodoView.init(store: )
                    )
                    
                    /*
                    ForEach(Array(viewStore.state.todos.enumerated()), id: \.element.id) { index, todo in
                        HStack {
                            Button {
                                viewStore.send(
                                    .todo(index: index,
                                          action: .checkboxTapped)
                                )
                            } label: {
                                Image(systemName: todo.isComplete ? "checkmark.square" : "square")
                            }
                            .buttonStyle(.plain)
                            
                            TextField(
                                "Untitled todo",
                                text: viewStore.binding(
                                    get: { $0.todos[index].description },
                                    send: { .todo(
                                        index: index,
                                        action: .textFieldChanged($0))
                                    })
                            )
                            
                        } //: HSTACK
                        .foregroundColor(todo.isComplete ? .gray : nil)
                    } //: FOREACH
                     */
                } //: LIST
                .navigationTitle("Todos")
                .navigationBarItems(trailing: Button("Add") {
                    viewStore.send(.addButtonTapped)
                })
            } //: VIEWSTORE
        } //: NAVIGATION VIEW
    }
}

struct TodoView: View {
    
    let store: Store<Todo, TodoAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Button {
                    viewStore.send(.checkboxTapped)
                } label: {
                    Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(.plain)
                
                /*
                TextField(
                    "Untitled todo",
                    text: viewStore.binding(
                        get: { $0.description },
                        send: {
                            .textFieldChanged($0)
                        })
                )
                 */
                
                TextField(
                    "Untitled todo",
                    text: viewStore.binding(
                        get: \.description,
                        send: TodoAction.textFieldChanged)
                )
                
            } //: HSTACK
            .foregroundColor(viewStore.isComplete ? .gray : nil)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store:
            Store(initialState: AppState(todos: [
                Todo(id: UUID(), description: "hello"),
                Todo(id: UUID(), description: "hello"),
            ]),
                  reducer: appReducer,
                  environment: AppEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    uuid: UUID.init
                  ))
        )
    }
}
