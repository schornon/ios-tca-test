//
//  PaymentFeature.swift
//  BooksSummary
//
//  Created by Serhii Chornonoh on 22.09.2024.
//

import Foundation
import ComposableArchitecture
import StoreKit

@Reducer
struct PaymentFeature {
    
    struct State: Equatable {
        var subscriptionProduct: Product?
        var subscriptionDisplayPrice: String {
            subscriptionProduct?.displayPrice ?? ""
        }
        @PresentationState var alert: AlertState<Action.Alert>?
        var isLoading: Bool = false
    }
    
    enum Action {
        case onAppear
        case loadProducts
        case loadProductsResult(Result<[Product], any Error>)
        case onBuySubscriptionTap
        case purchase(Product)
        case purchaseResult(Product.PurchaseResult)
        case purchaseTransaction(Transaction)
        case purchaseError(any Error) // Product.PurchaseError
        case alert(PresentationAction<Alert>)
        case finished
        
        enum Alert: Equatable {
            case errorOK
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadProducts)
                
            case .loadProducts:
                state.isLoading = true
                return .run { send in
                    let products = try await store.products()
                    await send(.loadProductsResult(.success(products)))
                } catch: { error, send in
                    await send(.loadProductsResult(.failure(error)))
                }
                
            case .loadProductsResult(.success(let products)):
                state.subscriptionProduct = products.filter({ $0.type == .autoRenewable }).first
                state.isLoading = false
                return .none
                
            case .loadProductsResult(.failure(let error)):
                state.alert = .loadProductsError(error)
                //state.isLoading = false
                return .none
                
            case .onBuySubscriptionTap:
                guard let product = state.subscriptionProduct else { return .none }
                return .send(.purchase(product))
                
            case .purchase(let product):
                return .run { send in
                    let transaction = try await store.purchase(product)
                    await send(.purchaseResult(transaction))
                } catch: { error, send in
                    await send(.purchaseError(error))
                }
                
            case .purchaseResult(let result):
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let signedType):
                        return .send(.purchaseTransaction(signedType))
                        
                    case .unverified(_, let error):
                        state.alert = .verificationError(error)
                        return .none
                    }
                    
                case .pending:
                    // depends on business logic
                    return .send(.finished)
                    
                case .userCancelled:
                    break
                    
                @unknown default:
                    // event to analytics/crashlytics
                    assertionFailure("can't handle unknown purchase result")
                }
                return .none
                
            case .purchaseTransaction(let transaction):
                return .run { send in
                    await transaction.finish()
                    await send(.finished)
                }
                
            case .purchaseError(let error):
                let purchaseError = (error as? Product.PurchaseError)
                state.alert = .purchaseError(purchaseError ?? error)
                return .none
                
            case .alert(.presented(.errorOK)):
                state.alert = nil
                return .none
                
            case .alert:
                return .none
                
            case .finished:
                return .none
                
            }
        }
    }
    
    @Dependency(\.store) var store
}

extension AlertState where Action == PaymentFeature.Action.Alert {
    static func purchaseError(_ error: any Error) -> Self {
        Self(
            title: { TextState("Payment error") },
            actions: { ButtonState(role: .cancel, action: .errorOK, label: { TextState("OK") }) },
            message: { TextState("Unfortunately, payment failed. Reason: \(error.localizedDescription)") }
        )
    }
    
    static func loadProductsError(_ error: any Error) -> Self {
        Self(
            title: { TextState("Error") },
            actions: { ButtonState(role: .cancel, action: .errorOK, label: { TextState("OK") }) },
            message: { TextState("Load products error. Please, try again later") }
        )
    }
    
    static func verificationError(_ error: any Error) -> Self {
        Self(
            title: { TextState("Verification error") },
            actions: { ButtonState(role: .cancel, action: .errorOK, label: { TextState("OK") }) },
            message: { TextState("Unfortunately, payment failed. Reason: \(error.localizedDescription)") }
        )
    }
}
