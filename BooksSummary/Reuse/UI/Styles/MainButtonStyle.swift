//
//  MainButtonStyle.swift
//  BooksSummary
//
//  Created by Serhii Chornonoh on 22.09.2024.
//

import SwiftUI

struct MainButtonStyle: ButtonStyle {
    
    var height: CGFloat = 50
    
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.6 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == MainButtonStyle {
    static var main: some ButtonStyle {
        MainButtonStyle()
    }
}

#Preview {
    Button("Button") {}
        .buttonStyle(.main)
}
