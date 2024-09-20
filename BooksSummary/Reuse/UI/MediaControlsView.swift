//
//  MediaControlsView.swift
//  BooksSummary
//
//  Created by Serhii Chornonoh on 20.09.2024.
//

import SwiftUI

struct MediaControlsView: View {
    let isPlaying: Bool
    let prevKeyPoint: () -> Void
    let seekBack: () -> Void
    let playPause: () -> Void
    let seekForward: () -> Void
    let nextKeyPoint: () -> Void
    
    var body: some View {
        HStack(spacing: 28) {
            PlayerControlButton("backward.end.fill", size: 26) {
                prevKeyPoint()
            }
            
            PlayerControlButton("gobackward.5", size: 30) {
                seekBack()
            }
            
            PlayerControlButton(isPlaying ? "pause.fill" : "play.fill") {
                playPause()
            }
            
            PlayerControlButton("goforward.10", size: 30) {
                seekForward()
            }
            
            PlayerControlButton("forward.end.fill", size: 26) {
                nextKeyPoint()
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
    MediaControlsView(isPlaying: false, prevKeyPoint: {}, seekBack: {}, playPause: {}, seekForward: {}, nextKeyPoint: {})
}
