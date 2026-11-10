//
//  ContactDetailTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Testing

@testable import TheNextBigStore

@Suite
struct ContactDetailTests {
    @Test(arguments: ["jane@example.com", "  jane.doe+shop@mail.example.com.au  "])
    func acceptsEmailAddresses(input: String) {
        #expect(ContactDetail(parsing: input) == .email(input.trimmingCharacters(in: .whitespaces)))
    }

    @Test(arguments: ["jane", "jane@", "@example.com", "jane@example", "jane @example.com", "jane@example.c"])
    func rejectsMalformedEmails(input: String) {
        #expect(ContactDetail(parsing: input) == nil)
    }

    @Test(arguments: [
        "0412 345 678", "0412345678", "+61 412 345 678", "+61412345678", "0061 412 345 678", "04-1234-5678",
    ])
    func normalisesAustralianMobiles(input: String) {
        #expect(ContactDetail(parsing: input) == .phone("+61412345678"))
    }

    @Test(arguments: [
        ("(02) 9876 5432", "+61298765432"),
        ("03 9876 5432", "+61398765432"),
        ("+61 7 3456 7890", "+61734567890"),
        ("08 9123 4567", "+61891234567"),
    ])
    func normalisesAustralianLandlines(input: String, expected: String) {
        #expect(ContactDetail(parsing: input) == .phone(expected))
    }

    @Test(arguments: [
        "1234", "0112345678", "04123456789", "041234567", "+44 7911 123456", "0412 345 67a", "+61 +412 345 678", "",
    ])
    func rejectsOtherNumbers(input: String) {
        #expect(ContactDetail(parsing: input) == nil)
    }

    @Test(arguments: [
        ("0412 345 678", "0412345678"),
        ("04-1234-5678", "0412345678"),
        ("+61 412 345 678", "0412345678"),
        ("0061 412 345 678", "0412345678"),
        ("04123456789", "0412345678"),
        ("04a1", "041"),
        ("61", "61"),
        ("", ""),
    ])
    func sanitisesPhoneInputToLocalDigits(input: String, expected: String) {
        #expect(ContactDetail.sanitizedAustralianDigits(from: input) == expected)
    }
}
