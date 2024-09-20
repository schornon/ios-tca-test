//
//  SliderView.swift
//  BooksSummary
//
//  Created by Serhii Chornonoh on 20.09.2024.
//


import SwiftUI

struct SliderView: View {
    @Binding var value: CGFloat
    var range: ClosedRange<CGFloat>
    var height: CGFloat = 16
    var progress: CGFloat {
        value * 100 / range.upperBound
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.black.opacity(0.07))
                    
                    Capsule()
                        .fill(.tint)
                        .frame(width: max(0, progressWidth(proxy)))
                    
                }
                .frame(height: height / 3)
                
                Circle()
                    .fill(.tint)
                    .position(x: progressWidth(proxy), y: height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { (gValue) in
                                let dx = gValue.location.x
                                let width = proxy.size.width
                                let res = dx / width * range.upperBound
                                self.value = max(range.lowerBound, min(res, range.upperBound))
                            }
                    )
            }
        }
        .frame(height: height)
    }
    
    private func progressWidth(_ proxy: GeometryProxy) -> CGFloat {
        proxy.size.width * progress / 100
    }
}

#Preview {
    SliderView(value: .constant(0), range: 0...10)
        .padding()
}
