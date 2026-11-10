//
//  EnquiryViewModelTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Foundation
import Testing

@testable import TheNextBigStore

@MainActor
@Suite
struct EnquiryViewModelTests {
    private func makeViewModel(
        repository: StubEnquiryRepository = StubEnquiryRepository()
    ) -> EnquiryViewModel {
        EnquiryViewModel(product: .fixture(id: 9, title: "Slim Shirt"), repository: repository)
    }

    private func fill(
        _ viewModel: EnquiryViewModel,
        method: EnquiryViewModel.ContactMethod = .email,
        contact: String = "jane@example.com"
    ) {
        viewModel.name = "  Jane Doe "
        viewModel.selectContactMethod(method)
        viewModel.updateContact(contact)
        viewModel.message = " Is this available in blue? "
    }

    // MARK: Validation

    @Test func startsEditingWithSubmitDisabledAndNoErrors() {
        let viewModel = makeViewModel()

        #expect(viewModel.phase == .editing)
        #expect(!viewModel.canSubmit)
        #expect(viewModel.nameError == nil)
        #expect(viewModel.contactError == nil)
        #expect(viewModel.messageError == nil)
    }

    @Test func submitEnablesOnlyOnceEveryFieldIsValid() {
        let viewModel = makeViewModel()

        viewModel.name = "Jane"
        #expect(!viewModel.canSubmit)

        viewModel.updateContact("jane@example.com")
        #expect(!viewModel.canSubmit)

        viewModel.message = "Hello"
        #expect(viewModel.canSubmit)
    }

    @Test func whitespaceOnlyFieldsDoNotCount() {
        let viewModel = makeViewModel()
        viewModel.name = "   "
        viewModel.updateContact("jane@example.com")
        viewModel.message = "\n"

        #expect(!viewModel.isValid)
    }

    @Test func invalidEmailKeepsSubmitDisabled() {
        let viewModel = makeViewModel()
        fill(viewModel, contact: "jane@")

        #expect(!viewModel.canSubmit)
    }

    @Test func tenDigitPhoneNumberIsAccepted() {
        let viewModel = makeViewModel()
        fill(viewModel, method: .phone, contact: "0412 345 678")

        #expect(viewModel.contact == "0412345678")
        #expect(viewModel.canSubmit)
    }

    @Test func incompleteOrNonAustralianPhoneNumbersAreRejected() {
        let viewModel = makeViewModel()

        fill(viewModel, method: .phone, contact: "04123")
        #expect(!viewModel.canSubmit)

        viewModel.updateContact("0112345678")
        #expect(!viewModel.canSubmit)
    }

    @Test func phoneInputIsReducedToLocalDigits() {
        let viewModel = makeViewModel()
        viewModel.selectContactMethod(.phone)

        viewModel.updateContact("+61 412-345-678")

        #expect(viewModel.contact == "0412345678")
    }

    @Test func emailModeRejectsAPhoneNumber() {
        let viewModel = makeViewModel()
        fill(viewModel, contact: "0412345678")

        #expect(!viewModel.canSubmit)
    }

    @Test func phoneModeRejectsAnEmailAddress() {
        let viewModel = makeViewModel()
        fill(viewModel, method: .phone, contact: "jane@example.com")

        #expect(viewModel.contact.isEmpty)
        #expect(!viewModel.canSubmit)
    }

    @Test func switchingMethodClearsTheContactAndItsError() {
        let viewModel = makeViewModel()
        viewModel.updateContact("jane@")
        viewModel.touch(.contact)
        #expect(viewModel.contactError == Constants.Enquiry.emailInvalid)

        viewModel.selectContactMethod(.phone)

        #expect(viewModel.contact.isEmpty)
        #expect(viewModel.contactError == nil)
    }

    @Test func contactErrorsMatchTheChosenMethod() {
        let viewModel = makeViewModel()
        viewModel.touch(.contact)
        #expect(viewModel.contactError == Constants.Enquiry.emailRequired)

        viewModel.updateContact("jane@")
        #expect(viewModel.contactError == Constants.Enquiry.emailInvalid)

        viewModel.selectContactMethod(.phone)
        viewModel.touch(.contact)
        #expect(viewModel.contactError == Constants.Enquiry.phoneRequired)

        viewModel.updateContact("04123")
        #expect(viewModel.contactError == Constants.Enquiry.phoneInvalid)
    }

    @Test func leavingAnEmptyFieldExplainsThatItIsRequired() {
        let viewModel = makeViewModel()
        viewModel.touch(.name)
        viewModel.touch(.contact)
        viewModel.touch(.message)

        #expect(viewModel.nameError == Constants.Enquiry.nameRequired)
        #expect(viewModel.contactError == Constants.Enquiry.emailRequired)
        #expect(viewModel.messageError == Constants.Enquiry.messageRequired)
    }

    @Test func errorsClearLiveOnceFixed() {
        let viewModel = makeViewModel()
        viewModel.touch(.name)
        #expect(viewModel.nameError != nil)

        viewModel.name = "Jane"

        #expect(viewModel.nameError == nil)
    }

    // MARK: Submitting

    @Test func submitDoesNothingWhileTheFormIsInvalid() async {
        let repository = StubEnquiryRepository()
        let viewModel = makeViewModel(repository: repository)

        await viewModel.submit()

        #expect(viewModel.phase == .editing)
        #expect(await repository.log.enquiries.isEmpty)
    }

    @Test func validSubmitSendsTrimmedEnquiryWithEmailContact() async {
        let repository = StubEnquiryRepository()
        let viewModel = makeViewModel(repository: repository)
        fill(viewModel)

        await viewModel.submit()

        #expect(viewModel.phase == .submitted)
        #expect(
            await repository.log.enquiries == [
                Enquiry(
                    productID: 9, productTitle: "Slim Shirt", name: "Jane Doe",
                    contact: .email("jane@example.com"), message: "Is this available in blue?"
                )
            ]
        )
    }

    @Test func phoneContactIsSentInInternationalFormat() async {
        let repository = StubEnquiryRepository()
        let viewModel = makeViewModel(repository: repository)
        fill(viewModel, method: .phone, contact: "0412 345 678")

        await viewModel.submit()

        #expect(await repository.log.enquiries.first?.contact == .phone("+61412345678"))
    }

    @Test func failedDeliveryKeepsTheFormAndAllowsRetry() async {
        let repository = StubEnquiryRepository(result: .failure(.badStatus(500)))
        let viewModel = makeViewModel(repository: repository)
        fill(viewModel)

        await viewModel.submit()
        #expect(viewModel.phase == .failed(NetworkError.badStatus(500).localizedDescription))
        #expect(viewModel.name == "  Jane Doe ")
        #expect(viewModel.canSubmit)

        await viewModel.submit()
        #expect(await repository.log.enquiries.count == 2)
    }

    @Test func ignoresASecondSubmitWhileOneIsInFlight() async throws {
        let repository = StubEnquiryRepository(delay: .milliseconds(100))
        let viewModel = makeViewModel(repository: repository)
        fill(viewModel)

        let first = Task { await viewModel.submit() }
        try await Task.sleep(for: .milliseconds(20))
        #expect(!viewModel.canSubmit)
        await viewModel.submit()
        await first.value

        #expect(await repository.log.enquiries.count == 1)
        #expect(viewModel.phase == .submitted)
    }
}
