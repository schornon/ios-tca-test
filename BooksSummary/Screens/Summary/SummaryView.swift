//
//  ContentView.swift
//  BooksSummary
//
//  Created by mbp2 hilfy on 11.12.2023.
//

import SwiftUI
import ComposableArchitecture

struct SummaryView: View {
    let store: StoreOf<Summary>
    @ObservedObject var viewStore: ViewStore<Summary.State, Summary.Action>
    
    init(store: StoreOf<Summary>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: {$0})
    }
    
    var body: some View {
        content
            .overlay {
                IfLetStore(store.scope(state: \.payment, action: \.payment)) { store in
                    PaymentView(store: store)
                        .animation(.easeInOut, value: viewStore.subscriptionActive)
                        .offset(y: viewStore.subscriptionActive ? 500 : 0)
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
    }
    
    var content: some View {
        VStack(spacing: 26) {
            bookCover
                .frame(width: 220, height: 320)
            
            VStack(spacing: 8) {
                let index = viewStore.keyPointIndex
                Text("KEY POINT \(index + 1) OF \(viewStore.book.keyPoints.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .opacity(0.4)
                
                Text(viewStore.keyPoint.shortText)
                    .font(.system(size: 14, weight: .regular))
                    .multilineTextAlignment(.center)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .padding(.horizontal)
            .layoutPriority(100)
            
            SummaryAudioControlsView(
                store: store.scope(state: \.audioControls, action: \.audioControls)
            )
            
            Toggle(
                "",
                isOn: viewStore.binding(get: \.isAudioMode, send: .onModeTap)
            )
            .toggleStyle(SummaryModeToggleStyle())
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 50)
        .padding(.horizontal)
        .padding(.bottom)
        .background(
            Color.milkBackground
        )
        .overlay(alignment: .topLeading) {
            Button(action: { store.send(.onBackTap) }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundStyle(.black)
                    .padding()
            }
        }
    }
    
    var bookCover: some View {
        AsyncImage(
            url: viewStore.bookCover,
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            },
            placeholder: {
                Color.black.opacity(0.1)
                    .overlay {
                        ProgressView()
                    }
            }
        )
    }
}

#Preview {
    SummaryView(
        store: Store(initialState: Summary.State(
            book: Book.mock, subscriptionActive: true)
        ) {
            Summary()
        }
    )
}
