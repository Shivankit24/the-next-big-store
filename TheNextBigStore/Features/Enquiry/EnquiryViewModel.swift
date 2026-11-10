//
//  EnquiryViewModel.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation
import Observation

/// Drives the enquiry form. Name, contact (email or Australian phone) and message are all
/// mandatory, and `canSubmit` stays false until every field is valid. A field's error appears
/// once the user has left it, and then updates as they type.
@Observable
final class EnquiryViewModel {
    enum Field: Hashable { case name, contact, message }

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
    private(set) var touchedFields: Set<Field> = []

    private let repository: any EnquiryRepository

    init(product: Product, repository: any EnquiryRepository) {
        self.product = product
        self.repository = repository
    }

    // MARK: Validation

    var isValid: Bool {
        !trimmed(name).isEmpty && ContactDetail(parsing: contact) != nil && !trimmed(message).isEmpty
    }

    var isSubmitting: Bool {
        phase == .submitting
    }

    /// Drives the Submit button: enabled only when the whole form is valid.
    var canSubmit: Bool {
        isValid && !isSubmitting
    }

    /// Marks a field as visited, which lets its error show. Call when the user leaves the field.
    func touch(_ field: Field) {
        touchedFields.insert(field)
    }

    var nameError: String? {
        guard touchedFields.contains(.name), trimmed(name).isEmpty else { return nil }
        return Constants.Enquiry.nameRequired
    }

    var contactError: String? {
        guard touchedFields.contains(.contact) else { return nil }
        if trimmed(contact).isEmpty { return Constants.Enquiry.contactRequired }
        return ContactDetail(parsing: contact) == nil ? Constants.Enquiry.contactInvalid : nil
    }

    var messageError: String? {
        guard touchedFields.contains(.message), trimmed(message).isEmpty else { return nil }
        return Constants.Enquiry.messageRequired
    }

    // MARK: Submitting

    func submit() async {
        guard canSubmit, let contactDetail = ContactDetail(parsing: contact) else { return }

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
