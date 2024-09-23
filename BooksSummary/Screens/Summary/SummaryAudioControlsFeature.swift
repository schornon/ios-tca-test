//
//  SummaryAudioControlsFeature.swift
//  BooksSummary
//
//  Created by Serhii Chornonoh on 20.09.2024.
//

import SwiftUI
import ComposableArchitecture
import CoreMedia

@Reducer
struct SummaryAudioControlsFeature {
    
    struct State: Equatable {
        var isPlaying: Bool = false
        var currentTime: CMTime = .zero
        var duration: CMTime = .zero
        var playbackRate: PlaybackRate = .x100
    }
    
    enum Action {
        case onAppear
        case setupObservers
        case playPause
        case isPlaying(Bool, _ passthrough: Bool = true)
    
        case mediaDuration(CMTime)
        case mediaCurrentTime(CMTime)
        case seekPlayerBy(CMTimeValue)
        case seekPlayerTo(CMTime)
        case playbackRate(PlaybackRate)
        case didPlayToEndTime
        
        case speedTapped
        case sliderValueChanged(CGFloat)

        case backwardAction
        case forwardAction
        case prevKeyPoint
        case nextKeyPoint
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.setupObservers)
                
            case .setupObservers:
                let playerStatusStream = mediaPlayer.playerTimeControlStatus()
                let itemDidPlayToEndStream = mediaPlayer.itemDidPlayToEndTime()
                let currentItemStream = mediaPlayer.currentItem()

                return .run { send in
                    await withTaskGroup(of: Void.self) { taskGroup in
                        taskGroup.addTask {
                            for await status in playerStatusStream {
                                await send(.isPlaying(status != .paused, false))
                            }
                        }
                        
                        taskGroup.addTask {
                            for await _ in itemDidPlayToEndStream {
                                await send(.didPlayToEndTime)
                            }
                        }
                        
                        taskGroup.addTask {
                            for await currentItem in currentItemStream {
                                let duration = try? await currentItem?.asset.load(.duration)
                                await send(.mediaDuration(duration ?? .zero))
                            }
                        }
                        
                        taskGroup.addTask {
                            for await currentTime in await mediaPlayer.currentTime() {
                                print(currentTime)
                                await send(.mediaCurrentTime(currentTime), animation: .linear(duration: 0.1))
                            }
                        }
                        
                        taskGroup.addTask {
                            for await playbackSpeed in await mediaPlayer.playbackRateStream() {
                                print(playbackSpeed)
                            }
                        }
                        
                        await taskGroup.waitForAll()
                    }
                }
                
            case .playPause:
                return .send(.isPlaying(!state.isPlaying))
                
            case .isPlaying(let value, let passthrough):
                state.isPlaying = value
                guard passthrough else { return .none }
                return .run { [isPlaying = state.isPlaying] _ in
                    isPlaying ? await mediaPlayer.play() : await mediaPlayer.pause()
                }
                
            case .mediaDuration(let time):
                state.duration = time
                return .none
                
            case .mediaCurrentTime(let time):
                state.currentTime = time
                return .none
                
            case .seekPlayerBy(let seconds):
                return .run { _ in
                    await mediaPlayer.seekBy(seconds: seconds)
                }
                
            case .seekPlayerTo(let time):
                return .run { _ in
                    await mediaPlayer.seekTo(time: time)
                }
                
            case .playbackRate(let rate):
                state.playbackRate = rate
                return .run { send in
                    await mediaPlayer.setPlaybackRate(rate)
                }
                
            case .didPlayToEndTime:
                return .send(.nextKeyPoint)
                
            case .speedTapped:
                let next = state.playbackRate.next()
                return .send(.playbackRate(next))
                
            case .sliderValueChanged(let value):
                let time = CMTime(seconds: value, preferredTimescale: 1000)
                return .send(.seekPlayerTo(time))
                
            case .backwardAction:
                return .send(.seekPlayerBy(-5))
                
            case .forwardAction:
                return .send(.seekPlayerBy(10))
                
            case .prevKeyPoint:
                return .none
                
            case .nextKeyPoint:
                return .none
                
            }
        }
    }
    
    @Dependency(\.mediaPlayer) var mediaPlayer
}
