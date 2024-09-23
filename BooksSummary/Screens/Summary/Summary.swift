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
        var subscriptionActive: Bool
        
        init(book: Book, subscriptionActive: Bool = false) {
            self.book = book
            self.subscriptionActive = subscriptionActive
            if !subscriptionActive {
                self.payment = .init()
            }
        }
        
        var payment: PaymentFeature.State?
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
        case onModeTap
        case onBackTap
        case audioControls(SummaryAudioControlsFeature.Action)
        case payment(PaymentFeature.Action)
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

            case .onModeTap:
                state.isAudioMode.toggle()
                return .none
                
            case .onBackTap:
                return .run { send in
                    await mediaPlayer.pause()
                    await dismiss()
                }

            case .audioControls(.prevKeyPoint):
                let newIndex = state.keyPointIndex - 1
                guard state.book.keyPoints.indices.contains(newIndex) else {
                    return .send(.audioControls(.seekPlayerTo(.zero)))
                }
                return .send(.keyPointIndex(newIndex))
                
            case .audioControls(.nextKeyPoint):
                let newIndex = state.keyPointIndex + 1
                guard state.book.keyPoints.indices.contains(newIndex) else {
                    return .run { send in
                        await send(.audioControls(.isPlaying(false)))
                        await send(.audioControls(.seekPlayerTo(.zero)))
                    }
                }
                return .send(.keyPointIndex(newIndex))
                
            case .payment(.finished):
                state.subscriptionActive = true
                return .none
                
            case .payment(.alert(.presented(.errorOK))):
                return .send(.onBackTap)
                
            case .audioControls:
                return .none
                
            case .payment:
                return .none
                
            }
        }
        .ifLet(\.payment, action: \.payment) {
            PaymentFeature()
        }
        
        Scope(state: \.audioControls, action: \.audioControls) {
            SummaryAudioControlsFeature()
        }
    }
    
    typealias Media = MediaPlayerClient.Media
    @Dependency(\.mediaPlayer) var mediaPlayer
    @Dependency(\.dismiss) var dismiss
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
