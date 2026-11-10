//
//  EnquiryEnvironment.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

extension EnvironmentValues {
    /// Builds the enquiry form's view model for a product. Injected once at the app root, so
    /// product pages can offer an enquiry without knowing how it is delivered.
    @Entry var makeEnquiryViewModel: (Product) -> EnquiryViewModel = { product in
        EnquiryViewModel(product: product, repository: UnconfiguredEnquiryRepository())
    }
}

/// Fallback used only if the app root forgets to inject a real repository: fails loudly in the
/// UI rather than pretending an enquiry was sent.
private nonisolated struct UnconfiguredEnquiryRepository: EnquiryRepository {
    func submit(_ enquiry: Enquiry) async throws {
        throw NetworkError.invalidURL
    }
}
