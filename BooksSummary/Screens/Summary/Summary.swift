//
//  Summary.swift
//  BooksSummary
//
//  Created by mbp2 hilfy on 12.12.2023.
//

import AVKit
import ComposableArchitecture
import CoreMedia

@Reducer
struct Summary {
    struct State: Equatable {
        var book: Book
        var bookCover: URL? {
            URL(string: book.coverPath)
        }
        var keyPointIndex: Int = 0
        var keyPoint: KeyPoint {
            book.keyPoints[keyPointIndex]
        }
        
        var audioControls: SummaryAudioControlsFeature.State = .init()
        var autoplay: Bool = false
        
        var isAudioMode: Bool = true
    }
    
    enum Action {
        case onAppear
        case keyPointIndex(Int)
        case loadKeyPoint
        case loadMedia(Media?)
        case autoplay(Bool)
        case modeTapped
        case audioControls(SummaryAudioControlsFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadKeyPoint)
                
            case .keyPointIndex(let index):
                state.keyPointIndex = index
                return .send(.loadKeyPoint)
                
            case .loadKeyPoint:
                guard
                    let url = URL(string: state.keyPoint.audioPath)
                else {
                    return .send(.loadMedia(nil))
                }
                
                let media = Media(url: url)
                return .send(.loadMedia(media))
                
            case .loadMedia(let media):
                return .run { [autoplay = state.autoplay] send in
                    try await mediaPlayer.load(media)
                    
                    if autoplay {
                        await send(.audioControls(.isPlaying(true)))
                    }
                    await send(.autoplay(true))
                }
              
            case .autoplay(let value):
                state.autoplay = value
                return .none

            case .modeTapped:
                state.isAudioMode.toggle()
                return .none

            case .audioControls(.prevKeyPoint):
                let newIndex = state.keyPointIndex - 1
                guard state.book.keyPoints.indices.contains(newIndex) else {
                    return .send(.audioControls(.seekPlayerTo(.zero)))
                }
                return .send(.keyPointIndex(newIndex))
                
            case .audioControls(.nextKeyPoint):
                let newIndex = state.keyPointIndex + 1
                guard state.book.keyPoints.indices.contains(newIndex) else {
                    return .send(.audioControls(.seekPlayerTo(.zero)))
                }
                return .send(.keyPointIndex(newIndex))
                
            case .audioControls:
                return .none
                
            }
        }
        
        Scope(state: \.audioControls, action: \.audioControls) {
            SummaryAudioControlsFeature()
        }
    }
    
    typealias Media = MediaPlayerClient.Media
    @Dependency(\.mediaPlayer) var mediaPlayer
}


extension PlaybackRate {
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
    
    var displayValue: String {
        return switch self {
        case .x050:
            "0.5"
        case .x075:
            "0.75"
        case .x100:
            "1"
        case .x125:
            "1.25"
        case .x150:
            "1.5"
        case .x175:
            "1.75"
        case .x200:
            "2"
        }
    }
}
