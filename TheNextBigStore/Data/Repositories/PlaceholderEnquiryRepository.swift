//
//  PlaceholderEnquiryRepository.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// MVP stand-in for enquiry delivery: accepts every enquiry and sends it nowhere.
///
/// The enquiry flow (validation, submit, thank-you) is fully usable, but nothing leaves the
/// device. When delivery is built, swap this for `RemoteEnquiryRepository` in `AppContainer`;
/// no screen or view model changes.
nonisolated struct PlaceholderEnquiryRepository: EnquiryRepository {
    func submit(_ enquiry: Enquiry) async throws {}
}
