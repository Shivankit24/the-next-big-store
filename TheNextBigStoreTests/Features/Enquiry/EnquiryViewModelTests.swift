//
//  EnquiryViewModelTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

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

    private func fill(_ viewModel: EnquiryViewModel, contact: String = "jane@example.com") {
        viewModel.name = "  Jane Doe "
        viewModel.contact = contact
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

        viewModel.contact = "jane@example.com"
        #expect(!viewModel.canSubmit)

        viewModel.message = "Hello"
        #expect(viewModel.canSubmit)
    }

    @Test func whitespaceOnlyFieldsDoNotCount() {
        let viewModel = makeViewModel()
        viewModel.name = "   "
        viewModel.contact = "jane@example.com"
        viewModel.message = "\n"

        #expect(!viewModel.isValid)
    }

    @Test func invalidContactKeepsSubmitDisabled() {
        let viewModel = makeViewModel()
        fill(viewModel, contact: "12345")

        #expect(!viewModel.canSubmit)
    }

    @Test func australianPhoneNumberIsAcceptedAsContact() {
        let viewModel = makeViewModel()
        fill(viewModel, contact: "0412 345 678")

        #expect(viewModel.canSubmit)
    }

    @Test func errorsStayHiddenUntilTheFieldHasBeenLeft() {
        let viewModel = makeViewModel()
        viewModel.contact = "12345"
        #expect(viewModel.contactError == nil)

        viewModel.touch(.contact)

        #expect(viewModel.contactError == Constants.Enquiry.contactInvalid)
        #expect(viewModel.nameError == nil)
    }

    @Test func leavingAnEmptyFieldExplainsThatItIsRequired() {
        let viewModel = makeViewModel()
        viewModel.touch(.name)
        viewModel.touch(.contact)
        viewModel.touch(.message)

        #expect(viewModel.nameError == Constants.Enquiry.nameRequired)
        #expect(viewModel.contactError == Constants.Enquiry.contactRequired)
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
        fill(viewModel, contact: "0412 345 678")

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
