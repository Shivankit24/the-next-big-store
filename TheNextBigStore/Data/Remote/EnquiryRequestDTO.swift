//
//  EnquiryRequestDTO.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// Wire format of an enquiry sent to the backend. Exactly one of `email` or `phone` is present;
/// the other key is omitted. Phone numbers are in international format (+61...).
nonisolated struct EnquiryRequestDTO: Encodable, Sendable {
    let productId: Int
    let productTitle: String
    let name: String
    let email: String?
    let phone: String?
    let message: String

    init(_ enquiry: Enquiry) {
        productId = enquiry.productID
        productTitle = enquiry.productTitle
        name = enquiry.name
        message = enquiry.message
        switch enquiry.contact {
        case .email(let address):
            email = address
            phone = nil
        case .phone(let number):
            email = nil
            phone = number
        }
    }
}
