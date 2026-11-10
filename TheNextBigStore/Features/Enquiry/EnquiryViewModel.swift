//
//  EnquiryViewModel.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation
import Observation

/// Drives the enquiry form. Name, contact and message are all mandatory, and `canSubmit` stays
/// false until every field is valid. The customer picks how to be reached: by email, or by
/// phone, where the +61 is fixed in the UI so they only type the 10 digits. A field's error
/// appears once the user has left it, and then updates as they type.
@Observable
final class EnquiryViewModel {
    enum Field: Hashable { case name, contact, message }

    enum ContactMethod: Hashable, CaseIterable { case email, phone }

    enum Phase: Equatable {
        case editing
        case submitting
        case submitted
        case failed(String)
    }

    let product: Product
    var name = ""
    private(set) var contact = ""
    var message = ""
    private(set) var contactMethod: ContactMethod = .email
    private(set) var phase: Phase = .editing
    private(set) var touchedFields: Set<Field> = []

    private let repository: any EnquiryRepository

    init(product: Product, repository: any EnquiryRepository) {
        self.product = product
        self.repository = repository
    }

    // MARK: Validation

    var isValid: Bool {
        !trimmed(name).isEmpty && contactDetail != nil && !trimmed(message).isEmpty
    }

    /// The contact as typed, valid for the chosen method only: a number typed in Email mode (or an
    /// address in Phone mode) is not accepted.
    private var contactDetail: ContactDetail? {
        guard let detail = ContactDetail(parsing: contact) else { return nil }
        switch (contactMethod, detail) {
        case (.email, .email), (.phone, .phone): return detail
        default: return nil
        }
    }

    /// Switches between email and phone, starting the contact field afresh.
    func selectContactMethod(_ method: ContactMethod) {
        guard method != contactMethod else { return }
        contactMethod = method
        contact = ""
        touchedFields.remove(.contact)
    }

    /// Sets the contact from what the user typed. Phone input is reduced to local digits.
    func updateContact(_ input: String) {
        contact = contactMethod == .phone ? ContactDetail.sanitizedAustralianDigits(from: input) : input
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
        let isEmail = contactMethod == .email
        if trimmed(contact).isEmpty {
            return isEmail ? Constants.Enquiry.emailRequired : Constants.Enquiry.phoneRequired
        }
        guard contactDetail == nil else { return nil }
        return isEmail ? Constants.Enquiry.emailInvalid : Constants.Enquiry.phoneInvalid
    }

    var messageError: String? {
        guard touchedFields.contains(.message), trimmed(message).isEmpty else { return nil }
        return Constants.Enquiry.messageRequired
    }

    // MARK: Submitting

    func submit() async {
        guard canSubmit, let contactDetail else { return }

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
