//
//  RemoteEnquiryRepository.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// `EnquiryRepository` that posts enquiries to the backend, which emails the sales inbox.
nonisolated struct RemoteEnquiryRepository: EnquiryRepository {
    private let client: any HTTPClient

    init(client: any HTTPClient) {
        self.client = client
    }

    func submit(_ enquiry: Enquiry) async throws {
        let body = try JSONEncoder().encode(EnquiryRequestDTO(enquiry))
        try await client.send(.enquiries(body: body))
    }
}
