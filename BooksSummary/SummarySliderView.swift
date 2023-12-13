//
//  SummarySliderView.swift
//  BooksSummary
//
//  Created by mbp2 hilfy on 12.12.2023.
//

import SwiftUI

struct SummarySliderView: View {
    @Binding var value: Int
    var seconds: ClosedRange<Int>
    
    var body: some View {
        HStack(spacing: 14) {
            Text(formatted(seconds: Int(value)))
                .frame(width: 40, alignment: .trailing)
                .foregroundStyle(.black.opacity(0.4))
            
            SliderView(
                value: Binding(
                    get: { CGFloat(value) },
                    set: { value = Int($0) }
                ),
                range: seconds.toCGFloat()
            )
            
            Text(formatted(seconds: Int(seconds.upperBound)))
                .frame(width: 40, alignment: .leading)
                .foregroundStyle(.black.opacity(0.3))
        }
        .font(.system(size: 14))
    }
    
    private func formatted(seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d", min, sec)
    }
    
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
                            .frame(width: progressWidth(proxy))
                        
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
}

fileprivate extension ClosedRange where Bound == Int {
    func toCGFloat() -> ClosedRange<CGFloat> {
        CGFloat(lowerBound)...CGFloat(upperBound)
    }
}

#Preview {
    struct Pw: View {
        @State var value: Int = 10
        
        var body: some View {
            SummarySliderView(value: $value, seconds: 0...72)
        }
    }
    
    return Pw()
        .padding()
        .background(.milkBackground)
}
