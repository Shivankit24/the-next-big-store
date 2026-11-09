//
//  RatingView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// A row of stars with the number of ratings beside it.
struct RatingView: View {
    let rate: Double
    let count: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(StarRating.fills(for: rate).enumerated()), id: \.offset) { _, fill in
                Image(systemName: fill.symbolName)
                    .foregroundStyle(.orange)
            }
            Text("(\(count))")
                .foregroundStyle(.secondary)
                .padding(.leading, 2)
        }
        .font(.caption)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Rated \(rate.formatted(.number.precision(.fractionLength(1)))) out of \(Constants.Rating.maxStars), \(count) ratings"
        )
    }
}

private extension StarRating.Fill {
    var symbolName: String {
        switch self {
        case .full: "star.fill"
        case .half: "star.leadinghalf.filled"
        case .empty: "star"
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        RatingView(rate: 3.9, count: 120)
        RatingView(rate: 4.6, count: 79)
        RatingView(rate: 2.1, count: 430)
    }
    .padding()
}
