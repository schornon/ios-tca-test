//
//  BooksSummaryApp.swift
//  BooksSummary
//
//  Created by mbp2 hilfy on 11.12.2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct BooksSummaryApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(store: Store(initialState: RootFeature.State()) {
                    RootFeature()
                }
            )
        }
    }
}
