//
//  RootFeatureView.swift
//  BooksSummary
//
//  Created by Serhii Chornonoh on 22.09.2024.
//
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<RootFeature>
    @ObservedObject var viewStore: ViewStore<RootFeature.State, RootFeature.Action>
    
    init(store: StoreOf<RootFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: {$0})
    }
    
    var body: some View {
        content
            .fullScreenCover(
                store: store.scope(state: \.$destination.summary, action: \.destination.summary)
            ) { store in
                SummaryView(store: store)
            }
            .onAppear {
                store.send(.onAppear)
            }
    }
    
    var content: some View {
        VStack {
            Button(action: { store.send(.onBookTap(.mock)) }) {
                Image(.duneCover)
                    .resizable()
                    .frame(width: 200, height: 300)
            }
        }
    }
}

#Preview {
    let store = Store(
        initialState: RootFeature.State(),
        reducer: RootFeature.init
    )
    
    return RootView(store: store)
}
