//
//  StoreClient.swift
//  BooksSummary
//
//  Created by Serhii Chornonoh on 22.09.2024.
//

import ComposableArchitecture
import CoreLocation
import StoreKit

extension DependencyValues {
    var store: StoreClient {
        get { self[StoreClient.self] }
        set { self[StoreClient.self] = newValue }
    }
}

@DependencyClient
struct StoreClient {
    var products: @Sendable () async throws -> [Product]
    var purchase: @Sendable (Product) async throws -> Product.PurchaseResult
    var purchaseWithOptions: @Sendable (Product, Set<Product.PurchaseOption>) async throws -> Product.PurchaseResult
    var transactionUpdates: @Sendable () -> AsyncStream<VerificationResult<Transaction>> = { .finished }
}

extension StoreClient: DependencyKey {
    static let liveValue: Self = {
        let actor = StoreActor()
        
        return Self(
            products: {
                try await actor.products()
            },
            purchase: { product in
                try await actor.purchase(product)
            },
            purchaseWithOptions: { product, options in
                try await actor.purchase(product, options: options)
            },
            transactionUpdates: {
                Transaction.updates.eraseToStream()
            }
        )
    }()
    
    actor StoreActor {
        
        func products() async throws -> [Product] {
            let bundleID = "com.cs.BooksSummary"
            let productIDs = [
                "\(bundleID).product.subscription.year"]
            let products = try await Product.products(for: productIDs)
            return products
        }
        
        func purchase(_ product: Product, options: Set<Product.PurchaseOption> = []) async throws -> Product.PurchaseResult {
            let result = try await product.purchase(options: options)
            return result
        }
    }
}
