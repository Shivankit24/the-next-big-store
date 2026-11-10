//
//  StubEnquiryRepository.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

@testable import TheNextBigStore

actor SubmissionLog {
    private(set) var enquiries: [Enquiry] = []

    func record(_ enquiry: Enquiry) { enquiries.append(enquiry) }
}

/// Records submitted enquiries and succeeds or fails as told.
struct StubEnquiryRepository: EnquiryRepository {
    var result: Result<Void, NetworkError> = .success(())
    var delay: Duration = .zero
    let log = SubmissionLog()

    func submit(_ enquiry: Enquiry) async throws {
        await log.record(enquiry)
        try await Task.sleep(for: delay)
        try result.get()
    }
}
