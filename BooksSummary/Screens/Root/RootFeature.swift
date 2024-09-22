//
//  RootFeature.swift
//  BooksSummary
//
//  Created by Serhii Chornonoh on 22.09.2024.
//
//

import Foundation
import ComposableArchitecture

@Reducer
struct RootFeature {
    
    @Reducer(state: .equatable)
    enum Destination {
        case summary(Summary)
    }
    
    struct State: Equatable {
        @PresentationState var destination: Destination.State?
    }
    
    enum Action {
        case onAppear
        case setupObservers
        case onBookTap(Book)
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.setupObservers)
                
            case .setupObservers:
                let transactionUpdatesStream = store.transactionUpdates()
                return .run { send in
                    await withTaskGroup(of: Void.self) { taskGroup in
                        
                        taskGroup.addTask {
                            for await item in transactionUpdatesStream {
                                if case let .verified(transaction) = item {
                                    await transaction.finish()
                                }
                            }
                        }
                    }
                }
                
            case .onBookTap(let book):
                state.destination = .summary(.init(book: book, subscriptionActive: false))
                return .none
                
            case .destination:
                return .none
                
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
    
    @Dependency(\.store) var store
}
