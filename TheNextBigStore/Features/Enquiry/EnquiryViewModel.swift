//
//  EnquiryViewModel.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation
import Observation

/// Drives the enquiry form. Name, contact (email or Australian phone) and message are all
/// mandatory. Errors stay hidden until the first submit attempt, then update as the user types.
@Observable
final class EnquiryViewModel {
    enum Field { case name, contact, message }

    enum Phase: Equatable {
        case editing
        case submitting
        case submitted
        case failed(String)
    }

    let product: Product
    var name = ""
    var contact = ""
    var message = ""
    private(set) var phase: Phase = .editing
    private(set) var showsValidation = false

    private let repository: any EnquiryRepository

    init(product: Product, repository: any EnquiryRepository) {
        self.product = product
        self.repository = repository
    }

    // MARK: Validation

    var nameError: String? {
        guard showsValidation, trimmed(name).isEmpty else { return nil }
        return Constants.Enquiry.nameRequired
    }

    var contactError: String? {
        guard showsValidation else { return nil }
        if trimmed(contact).isEmpty { return Constants.Enquiry.contactRequired }
        return ContactDetail(parsing: contact) == nil ? Constants.Enquiry.contactInvalid : nil
    }

    var messageError: String? {
        guard showsValidation, trimmed(message).isEmpty else { return nil }
        return Constants.Enquiry.messageRequired
    }

    /// The first field, top to bottom, whose current value is invalid, regardless of whether
    /// its error is showing yet. Used to move focus there after a failed submit attempt.
    var firstInvalidField: Field? {
        if trimmed(name).isEmpty { return .name }
        if ContactDetail(parsing: contact) == nil { return .contact }
        if trimmed(message).isEmpty { return .message }
        return nil
    }

    var isSubmitting: Bool {
        phase == .submitting
    }

    // MARK: Submitting

    func submit() async {
        guard !isSubmitting else { return }
        showsValidation = true
        guard firstInvalidField == nil, let contactDetail = ContactDetail(parsing: contact) else { return }

        phase = .submitting
        let enquiry = Enquiry(
            productID: product.id,
            productTitle: product.title,
            name: trimmed(name),
            contact: contactDetail,
            message: trimmed(message)
        )
        do {
            try await repository.submit(enquiry)
            phase = .submitted
        } catch {
            phase = Task.isCancelled ? .editing : .failed(error.localizedDescription)
        }
    }

    private func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
