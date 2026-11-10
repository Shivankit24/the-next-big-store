//
//  ContactDetail.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// How a customer can be reached: a valid email address or an Australian phone number.
nonisolated enum ContactDetail: Equatable, Sendable {
    case email(String)
    /// An Australian number in international format, e.g. "+61412345678".
    case phone(String)

    /// Parses what a customer typed into one field. Accepts an email address, or an Australian
    /// mobile (04...) or landline (02, 03, 07, 08) number written locally or as +61, with spaces,
    /// hyphens or brackets. Returns `nil` for anything else.
    init?(parsing input: String) {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if Self.isValidEmail(text) {
            self = .email(text)
        } else if let phone = Self.internationalNumber(fromAustralian: text) {
            self = .phone(phone)
        } else {
            return nil
        }
    }

    private static func isValidEmail(_ text: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    private static func internationalNumber(fromAustralian text: String) -> String? {
        guard !text.isEmpty, text.allSatisfy({ "0123456789+ -()".contains($0) }) else { return nil }

        var number = text.filter { "0123456789+".contains($0) }
        if number.hasPrefix("+61") {
            number = "0" + String(number.dropFirst(3))
        } else if number.hasPrefix("0061") {
            number = "0" + String(number.dropFirst(4))
        }

        // Ten digits, starting 0, then a mobile (4) or landline (2, 3, 7, 8) area digit.
        guard number.count == 10,
              number.allSatisfy(\.isNumber),
              number.hasPrefix("0"),
              let areaDigit = number.dropFirst().first,
              "23478".contains(areaDigit)
        else { return nil }

        return "+61" + String(number.dropFirst())
    }
}
