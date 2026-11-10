//
//  EnquiryViewModelFactory.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// Builds enquiry view models. A small object rather than a closure so it can live in the
/// SwiftUI environment: SwiftUI can compare an object's identity, but not a closure, and would
/// otherwise have to assume a closure changed on every update.
final class EnquiryViewModelFactory {
    private let repository: any EnquiryRepository

    init(repository: any EnquiryRepository) {
        self.repository = repository
    }

    func make(for product: Product) -> EnquiryViewModel {
        EnquiryViewModel(product: product, repository: repository)
    }
}
