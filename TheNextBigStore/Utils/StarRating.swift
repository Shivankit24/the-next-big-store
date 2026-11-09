//
//  StarRating.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// Turns a numeric rating into a row of full, half and empty stars.
nonisolated enum StarRating {
    enum Fill: Equatable, Sendable {
        case full
        case half
        case empty
    }

    /// Rounds `rate` to the nearest half star and clamps it to `0...maxStars`.
    static func fills(for rate: Double, maxStars: Int = Constants.Rating.maxStars) -> [Fill] {
        let clamped = min(max(rate, 0), Double(maxStars))
        let halves = Int((clamped * 2).rounded())
        return (0..<maxStars).map { index in
            switch halves - index * 2 {
            case 2...: .full
            case 1: .half
            default: .empty
            }
        }
    }
}
