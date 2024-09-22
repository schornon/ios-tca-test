//
//  PaymentView.swift
//  BooksSummary
//
//  Created by Serhii Chornonoh on 22.09.2024.
//

import SwiftUI
import ComposableArchitecture

struct PaymentView: View {
    let store: StoreOf<PaymentFeature>
    @ObservedObject var viewStore: ViewStore<PaymentFeature.State, PaymentFeature.Action>
    
    init(store: StoreOf<PaymentFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: {$0})
    }
    
    var body: some View {
        content
            .alert(store: store.scope(state: \.$alert, action: \.alert))
            .onAppear {
                store.send(.onAppear)
            }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            Spacer()
            
            LinearGradient(colors: [.milkBackground, .clear], startPoint: .bottom, endPoint: .top)
                .frame(height: 140)
            
            VStack(spacing: 24) {
                VStack(spacing: 14) {
                    Text("Unlock learning")
                        .font(.system(size: 36, weight: .bold))
                    
                    Text("Grow on the go by listening and reading the word's best ideas")
                        .font(.system(size: 16, weight: .regular))
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                if viewStore.isLoading {
                    loadingView
                } else {
                    Button("Start Listening • \(viewStore.subscriptionDisplayPrice)") {
                        store.send(.onBuySubscriptionTap)
                    }
                    .buttonStyle(.main)
                }
                
            }
            .padding()
            .background(Color.milkBackground)
        }
    }
    
    var loadingView: some View {
        Color.clear
            .frame(height: 50)
            .overlay {
                ProgressView()
            }
    }
}

#Preview {
    let store = Store(
        initialState: PaymentFeature.State(),
        reducer: PaymentFeature.init
    )
    
    return Color.black.opacity(0.3)
        .overlay {
            PaymentView(store: store)
        }
}

