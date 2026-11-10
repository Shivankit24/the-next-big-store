//
//  EnquiryRepository.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// Delivers enquiries to the sales team. Features depend on this protocol only, so the
/// delivery mechanism (and the email provider behind it) can change without touching them.
nonisolated protocol EnquiryRepository: Sendable {
    func submit(_ enquiry: Enquiry) async throws
}
