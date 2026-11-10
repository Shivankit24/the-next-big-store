//
//  HTTPMethod.swift
//  TheNextBigStore
//
//  Created by Shivankit on 09/11/26.
//

import Foundation

/// HTTP verbs the app uses.
nonisolated enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
}
