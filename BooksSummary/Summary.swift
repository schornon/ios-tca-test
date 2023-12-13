//
//  Summary.swift
//  BooksSummary
//
//  Created by mbp2 hilfy on 12.12.2023.
//

import AVKit
import ComposableArchitecture

@Reducer
struct Summary {
    struct State: Equatable {
        var book: Book
        var currentKeyPointIndex: Int = 0
        var currentKeyPoint: KeyPoint {
            book.keyPoints[currentKeyPointIndex]
        }
        var isPlaying: Bool = true
        var playerCurrentSecond: Int = 0
        var speed: Speed = .x100
        var isAudioMode: Bool = true
        
        struct Book: Equatable {
            let coverPath: String
            let keyPoints: [KeyPoint]
        }
        
        struct KeyPoint: Equatable {
            let shortText: String
            let audioPath: String
            //let text: String
            
            // fetch audio duration from the real file
            // var duration: Int {}
            let duration = Int.random(in: 60...120)
        }
        
        enum Speed: Equatable, CaseIterable {
            case x050, x075, x100, x125, x150, x175, x200
            
            mutating func next() {
                let all = Self.allCases
                let idx = all.firstIndex(of: self)!
                let next = all.index(after: idx)
                self = all[next == all.endIndex ? all.startIndex : next]
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
    }
    
    enum Action {
        case playPauseTapped
        case rewindBy(Int)
        case prevKeyPoint
        case nextKeyPoint
        case rewindToStart
        case speedTapped
        case modeTapped
        case sliderValueChanged(Int)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .playPauseTapped:
                state.isPlaying.toggle()
                return .none
                
            case .rewindBy(let value):
                let range = 0...state.currentKeyPoint.duration
                let current = state.playerCurrentSecond
                let newValue: Int = current + value
                state.playerCurrentSecond = max(range.lowerBound, min(newValue, range.upperBound))
                return .none
                
            case .prevKeyPoint:
                let newIndex = state.currentKeyPointIndex - 1
                guard state.book.keyPoints.indices.contains(newIndex) else { return .send(.rewindToStart) }
                state.currentKeyPointIndex = newIndex
                return .send(.rewindToStart)
                
            case .nextKeyPoint:
                let newIndex = state.currentKeyPointIndex + 1
                guard state.book.keyPoints.indices.contains(newIndex) else { return .send(.rewindToStart) }
                state.currentKeyPointIndex = newIndex
                return .send(.rewindToStart)
                
            case .rewindToStart:
                state.playerCurrentSecond = 0
                return .none
                
            case .speedTapped:
                state.speed.next()
                return .none
                
            case .modeTapped:
                state.isAudioMode.toggle()
                return .none
                
            case .sliderValueChanged(let value):
                state.playerCurrentSecond = value
                return .none
            }
        }
    }
}
