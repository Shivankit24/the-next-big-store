//
//  PriceFormatter.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// Formats product prices for display. The catalogue sells in Australian dollars.
nonisolated enum PriceFormatter {
    static func string(from price: Double) -> String {
        price.formatted(
            .currency(code: Constants.Currency.code)
                .locale(Locale(identifier: Constants.Currency.localeIdentifier))
        )
    }
}
