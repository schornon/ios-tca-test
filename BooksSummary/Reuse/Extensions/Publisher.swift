//
//  Publisher.swift
//  BooksSummary
//
//  Created by Serhii Chornonoh on 20.09.2024.
//

import Combine

extension Publisher where Failure == Never {
    public var stream: AsyncStream<Output> {
        AsyncStream { continuation in
            let cancellable = self.sink { completion in
                continuation.finish()
            } receiveValue: { value in
                 continuation.yield(value)
            }
            continuation.onTermination = { continuation in
                cancellable.cancel()
            }
        }
    }
}
