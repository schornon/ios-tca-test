//
//  SummaryAudioControlsView.swift
//  BooksSummary
//
//  Created by Serhii Chornonoh on 20.09.2024.
//


import SwiftUI
import ComposableArchitecture

struct SummaryAudioControlsView: View {
    let store: StoreOf<SummaryAudioControlsFeature>
    @ObservedObject var viewStore: ViewStore<SummaryAudioControlsFeature.State, SummaryAudioControlsFeature.Action>
    
    init(store: StoreOf<SummaryAudioControlsFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: {$0})
    }
    
    var body: some View {
        VStack(spacing: 26) {
            SummarySliderView(
                currentTime: viewStore.binding(
                    get: \.currentTime.floatValue,
                    send: { .sliderValueChanged($0) }
                ),
                duration: viewStore.duration.floatValue
            )
            
            SpeedButton(
                speed: viewStore.playbackRate,
                tapAction: { viewStore.send(.speedTapped, animation: nil) }
            )
            
            MediaControlsView(
                isPlaying: viewStore.isPlaying,
                prevKeyPoint: { store.send(.prevKeyPoint) },
                seekBack: { store.send(.backwardAction) },
                playPause: { store.send(.playPause, animation: nil) },
                seekForward: { store.send(.forwardAction) },
                nextKeyPoint: { store.send(.nextKeyPoint) }
            )
        }
        .onAppear {
            store.send(.setupObservers)
        }
    }
    
    struct SpeedButton: View {
        let speed: PlaybackRate
        let tapAction: () -> Void
        
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
}
