//
//  StarRatingTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Testing

@testable import TheNextBigStore

@Suite
struct StarRatingTests {
    @Test func roundsToNearestHalfStar() {
        #expect(StarRating.fills(for: 3.9) == [.full, .full, .full, .full, .empty])
        #expect(StarRating.fills(for: 4.6) == [.full, .full, .full, .full, .half])
        #expect(StarRating.fills(for: 2.1) == [.full, .full, .empty, .empty, .empty])
    }

    @Test func handlesBounds() {
        #expect(StarRating.fills(for: 0) == Array(repeating: .empty, count: 5))
        #expect(StarRating.fills(for: 5) == Array(repeating: .full, count: 5))
    }

    @Test func clampsOutOfRangeValues() {
        #expect(StarRating.fills(for: -1) == Array(repeating: .empty, count: 5))
        #expect(StarRating.fills(for: 9) == Array(repeating: .full, count: 5))
    }
}
