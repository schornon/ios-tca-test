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
    typealias ViewStoreType = ViewStore<Summary.State, Summary.Action>
    typealias Book = Summary.State.Book
    typealias KeyPoint = Summary.State.KeyPoint
    
    var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            content(viewStore)
        }
    }
    
    func content(_ viewStore: ViewStoreType) -> some View {
        VStack(spacing: 26) {
            Image("dune-cover") // viewStore.book.coverPath
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 300)
            
            VStack(spacing: 8) {
                let index = viewStore.currentKeyPointIndex
                Text("KEY POINT \(index + 1) OF \(viewStore.book.keyPoints.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .opacity(0.4)
                
                Text(viewStore.currentKeyPoint.shortText)
                    .font(.system(size: 14, weight: .regular))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
            
            SummarySliderView(
                value: viewStore.binding(
                    get: \.playerCurrentSecond,
                    send: { .sliderValueChanged($0) }
                ),
                seconds: 0...viewStore.currentKeyPoint.duration)
            
            SpeedButton(
                speed: viewStore.speed,
                tapAction: { viewStore.send(.speedTapped, animation: nil) }
            )
            
            HStack(spacing: 20) {
                PlayerControlButton("backward.end.fill", size: 26) {
                    viewStore.send(.prevKeyPoint)
                }
                
                PlayerControlButton("gobackward.5", size: 30) {
                    viewStore.send(.rewindBy(-5))
                }
                
                PlayerControlButton(viewStore.isPlaying ? "pause.fill" : "play.fill") {
                    viewStore.send(.playPauseTapped, animation: nil)
                }
                
                PlayerControlButton("goforward.10", size: 30) {
                    viewStore.send(.rewindBy(10))
                }
                
                PlayerControlButton("forward.end.fill", size: 26) {
                    viewStore.send(.nextKeyPoint)
                }
            }
            
            Toggle(
                "",
                isOn: viewStore.binding(get: \.isAudioMode, send: .modeTapped)
            )
            .toggleStyle(SummaryModeToggleStyle())
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 30)
        .background(
            Color.milkBackground
        )
    }
    
    struct SpeedButton: View {
        let speed: Speed
        let tapAction: () -> Void
        typealias Speed = Summary.State.Speed
        
        var body: some View {
            Button(action: tapAction) {
                Text("Speed x\(speed.displayValue)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.black.opacity(0.07))
                    )
            }
        }
    }
    
    struct PlayerControlButton: View {
        let systemName: String
        var size: CGFloat
        let action: () -> Void
        
        init(_ systemName: String, size: CGFloat = 40, action: @escaping () -> Void) {
            self.systemName = systemName
            self.size = size
            self.action = action
        }
        
        var body: some View {
            Button(action: action) {
                Image(systemName: systemName)
                    .font(.system(size: size))
                    .frame(width: size, height: size)
            }
            .tint(.black)
        }
    }
}

#Preview {
    SummaryView(
        store: Store(initialState: Summary.State(
            book: Fake.book)
        ) {
            Summary()
        }
    )
}


struct Fake {
    static var book: Summary.State.Book {
        .init(
            coverPath: "https://",
            keyPoints: [.init(shortText: "The number of the chapter is one. This chapter is perfect.", audioPath: "https://"),
                        .init(shortText: "The number of the chapter is two. This chapter is the center of the book. Something intresting you can find there.", audioPath: "https://"),
                        .init(shortText: "The number of the chapter is three. It's Briliant!", audioPath: "https://"),
                       ]
        )
    }
}
