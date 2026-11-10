//
//  EnquiryEndpoints.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

extension Endpoint {
    /// `POST /enquiries` with a JSON body.
    nonisolated static func enquiries(body: Data) -> Endpoint {
        Endpoint(
            path: "/enquiries",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: body
        )
    }
}
