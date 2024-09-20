//
//  SummarySliderView.swift
//  BooksSummary
//
//  Created by mbp2 hilfy on 12.12.2023.
//

import SwiftUI
import CoreMedia

struct SummarySliderView: View {
    @Binding var currentTime: CGFloat
    var duration: CGFloat
    
    var body: some View {
        HStack(spacing: 14) {
            Text(formatted(currentTime))
                .frame(width: 40, alignment: .trailing)
                .foregroundStyle(.black.opacity(0.4))
                .animation(nil, value: currentTime)
            
            SliderView(
                value: Binding(
                    get: { currentTime },
                    set: { currentTime = $0 }
                ),
                range: 0...duration
            )
            
            Text(formatted(duration))
                .frame(width: 40, alignment: .leading)
                .foregroundStyle(.black.opacity(0.3))
        }
        .font(.system(size: 14))
    }
    
    private func formatted(_ value: CGFloat) -> String {
        let seconds = Int(value)
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d", min, sec)
    }
}

#Preview {
    struct Pw: View {
        @State var value: CGFloat = 10
        let duration: CGFloat = 40
        
        var body: some View {
            SummarySliderView(currentTime: $value, duration: duration)
        }
    }
    
    return Pw()
        .padding()
        .background(.milkBackground)
}
