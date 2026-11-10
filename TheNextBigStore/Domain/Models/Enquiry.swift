//
//  Enquiry.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// A customer's enquiry about a product, ready to send to the sales team.
nonisolated struct Enquiry: Equatable, Sendable {
    let productID: Int
    let productTitle: String
    let name: String
    let contact: ContactDetail
    let message: String
}
