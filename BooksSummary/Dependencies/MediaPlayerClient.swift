//
//  MediaPlayerClient.swift
//  BooksSummary
//
//  Created by Serhii Chornonoh on 20.09.2024.
//


import ComposableArchitecture
import AVKit
import MediaPlayer
import Combine

extension DependencyValues {
    var mediaPlayer: MediaPlayerClient {
        get { self[MediaPlayerClient.self] }
        set { self[MediaPlayerClient.self] = newValue }
    }
}

// MARK: - Client
@DependencyClient
struct MediaPlayerClient {
    var load: @Sendable (Media?) async throws -> Void
    var player: @Sendable () -> AVPlayer = { AVPlayer() }
    var play: @Sendable () async -> Void
    var pause: @Sendable () async -> Void
    var playbackRate: @Sendable () async -> PlaybackRate = { .x100 }
    var setPlaybackRate: @Sendable (PlaybackRate) async -> Void
    var playbackRateStream: @Sendable () -> AsyncStream<PlaybackRate> = { .finished }
    var seekBy: @Sendable (_ seconds: CMTimeValue) async -> Void
    var seekTo: @Sendable (_ time: CMTime) async -> Void
    var playerTimeControlStatus: @Sendable () -> AsyncStream<AVPlayer.TimeControlStatus> = { .finished }
    var itemDidPlayToEndTime: @Sendable () -> AsyncStream<Void> = { .finished }
    var currentItem: @Sendable () -> AsyncStream<AVPlayerItem?> = { .finished }
    var currentTime: @Sendable () -> AsyncStream<CMTime> = { .finished }
    
    struct Media: Hashable {
        let url: URL
    }
}

// MARK: - Live
extension MediaPlayerClient: DependencyKey {
    static let liveValue: MediaPlayerClient = {
        let actor = MediaPlayerActor()
        return Self(
            load: { media in
                try await actor.load(media: media)
            },
            player: {
                actor.player
            },
            play: {
                await actor.play()
            },
            pause: {
                await actor.pause()
            },
            playbackRate: {
                actor.playbackRate.value
            },
            setPlaybackRate: { rate in
                actor.setPlaybackRate(rate)
            },
            playbackRateStream: {
                actor.playbackRateStream()
            },
            seekBy: { seconds in
                actor.seekBy(seconds)
            },
            seekTo: { time in
                actor.seekTo(time)
            },
            playerTimeControlStatus: {
                actor.player.publisher(for: \.timeControlStatus).stream
            },
            itemDidPlayToEndTime: {
                AsyncStream(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime).map({ _ in }).values)
            },
            currentItem: {
                actor.player.publisher(for: \.currentItem).stream
            },
            currentTime: {
                actor.currentTimeStream()
            }
        )
    }()
    
    private actor MediaPlayerActor {
        let player: AVPlayer
        let playbackRate: CurrentValueSubject<PlaybackRate, Never>
        
        init() {
            self.player = AVPlayer()
            self.playbackRate = CurrentValueSubject(.x100)
        }
        
        @MainActor
        func load(media: Media?) async throws {
            await pause()
            if let media {
                let newItem = AVPlayerItem(url: media.url)
                player.replaceCurrentItem(with: newItem)
            } else {
                player.replaceCurrentItem(with: nil)
            }
        }
        
        func play() async {
            player.rate = playbackRate.value.rawValue
        }
        
        func pause() async {
            player.pause()
        }
        
        func setPlaybackRate(_ rate: PlaybackRate) {
            playbackRate.send(rate)
            if player.timeControlStatus == .playing {
                player.rate = rate.rawValue
            }
        }
        
        func seekBy(_ seconds: CMTimeValue) {
            let currentTime = player.currentTime()
            let newTime = CMTimeAdd(currentTime, CMTime(value: seconds, timescale: 1))
            player.seek(to: newTime, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity)
        }
        
        func seekTo(_ newTime: CMTime) {
            player.seek(to: newTime, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity)
        }
        
        nonisolated
        func currentTimeStream() -> AsyncStream<CMTime> {
            AsyncStream { continuation in
                let interval = CMTime(value: 1, timescale: 10)
                let timeObserver: AnyObject? = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
                    continuation.yield(time)
                } as AnyObject
                continuation.onTermination = { [weak self, weak timeObserver] _ in
                    guard let self, let obs = timeObserver else { return }
                    player.removeTimeObserver(obs)
                    timeObserver = nil
                }
            }
        }
        
        nonisolated
        func playbackRateStream() -> AsyncStream<PlaybackRate> {
            AsyncStream(playbackRate.values)
        }
    }
}

enum PlaybackRate: Float, CaseIterable, Identifiable {
    case x050 = 0.50
    case x075 = 0.75
    case x100 = 1.00
    case x125 = 1.25
    case x150 = 1.50
    case x175 = 1.75
    case x200 = 2.00
    
    var id: Float {
        rawValue
    }
}
