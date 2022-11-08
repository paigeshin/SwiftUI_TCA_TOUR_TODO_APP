//
//  TCA_TODO_TOURTests.swift
//  TCA_TODO_TOURTests
//
//  Created by paige shin on 2022/11/09.
//

import ComposableArchitecture
import XCTest
@testable import TCA_TODO_TOUR

class TodosTests: XCTestCase {
    
    let scheduler = DispatchQueue.test
    
    func testCompletingTodo() {
        let store = TestStore(
            initialState: AppState(
                todos: [
                    Todo(
                        id: UUID(),
                        description: "Milk",
                        isComplete: false
                    )
                ]
            ),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { fatalError("unimplemented") }
            )
        )
        
        store.assert(
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = true
            },
            .do {
                // Do any imperative work
//                _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
                self.scheduler.advance(by: 1)
            },
            .receive(.todoDelayCompleted)
        )
    
    }
    
    func testAddTodo() {
        let store = TestStore(
            initialState: AppState(todos: []),
            reducer: appReducer,
            environment: AppEnvironment(mainQueue: scheduler.eraseToAnyScheduler(),
                                        uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")! })
        )
        
        store.assert(
            .send(.addButtonTapped) {
                $0.todos = [
                    Todo(id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!,
                         description: "",
                         isComplete: false)
                ]
            }
        )
    }
    
    func testTodoSorting() {
        let store = TestStore(
            initialState: AppState(todos: [
                Todo(
                    id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!,
                    description: "Milk",
                    isComplete: false
                ),
                Todo(
                    id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAA")!,
                    description: "Smile",
                    isComplete: false
                )
            ]),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { fatalError("unimplemented") }
            )
        )

        store.assert(
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = true
            },
            .do {
                // Do any imperative work
//                _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
                self.scheduler.advance(by: 1)
            },
            .receive(.todoDelayCompleted) {
                $0.todos.swapAt(0, 1)
            }
        )
    }
    
    func testTodoSorting_Cancellation() {
        let store = TestStore(
            initialState: AppState(todos: [
                Todo(
                    id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!,
                    description: "Milk",
                    isComplete: false
                ),
                Todo(
                    id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAA")!,
                    description: "Smile",
                    isComplete: false
                )
            ]),
            reducer: appReducer,
            environment: AppEnvironment(mainQueue: scheduler.eraseToAnyScheduler(),
                                        uuid: { fatalError("unimplemented") })
        )

        store.assert(
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = true
            },
            .do {
                // Do any imperative work
//                _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 0.5)
                self.scheduler.advance(by: 0.5)
            },
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = false
            },
            .do {
                // Do any imperative work
//                _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
                self.scheduler.advance(by: 1)
            },
            .receive(.todoDelayCompleted)
        )
    }
    
}
