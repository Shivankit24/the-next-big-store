//
//  AppContainer.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// Composition root: builds the app's dependencies once and hands them to features.
/// Swap implementations here (data source, email provider) without touching features.
struct AppContainer {
    let productRepository: any ProductRepository

    static let live = AppContainer(
        productRepository: RemoteProductRepository(client: URLSessionHTTPClient())
    )

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(repository: productRepository)
    }
}
