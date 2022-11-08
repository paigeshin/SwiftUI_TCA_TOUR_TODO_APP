//
//  TCA_TODO_TOURApp.swift
//  TCA_TODO_TOUR
//
//  Created by paige shin on 2022/11/09.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCA_TODO_TOURApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store:
                Store(initialState: AppState(todos: [
                    Todo(id: UUID(), description: "hello"),
                    Todo(id: UUID(), description: "world"),
                ]),
                      reducer: appReducer,
                      environment: AppEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                                                  uuid: UUID.init))
            )
        }
    }
}
