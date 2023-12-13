//
//  SummaryModeToggleStyle.swift
//  BooksSummary
//
//  Created by mbp2 hilfy on 12.12.2023.
//

import SwiftUI

struct SummaryModeToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Capsule()
            .stroke(.grayBorder, lineWidth: 2)
            .fill(Color.white)
            .frame(width: 112, height: 56)
            .overlay(alignment: configuration.isOn ? .leading : .trailing) {
                Circle()
                    .foregroundStyle(.blue)
                    .padding(4)
            }
            .overlay {
                HStack {
                    icon("headphones", configuration.isOn)
                    
                    Spacer()
                    
                    icon("text.alignleft", !configuration.isOn)
                }
                .padding(.horizontal, 17)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
            .animation(.easeInOut, value: configuration.isOn)
    }
    
    private func icon(_ systemName: String, _ active: Bool) -> some View {
        Image(systemName: systemName)
            .fontWeight(.bold)
            .foregroundStyle(active ? .white : .black)
    }
}


#Preview {
    struct Pw: View {
        @State var isOn: Bool = true
        
        var body: some View {
            Toggle("", isOn: $isOn)
                .toggleStyle(SummaryModeToggleStyle())
        }
    }
    
    return Pw()
}
