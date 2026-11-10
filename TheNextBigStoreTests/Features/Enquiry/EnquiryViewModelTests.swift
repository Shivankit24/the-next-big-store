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

    @Test func startsEditingWithNoErrorsShown() {
        let viewModel = makeViewModel()

        #expect(viewModel.phase == .editing)
        #expect(viewModel.nameError == nil)
        #expect(viewModel.contactError == nil)
        #expect(viewModel.messageError == nil)
    }

    @Test func submittingEmptyFormShowsEveryErrorAndSendsNothing() async {
        let repository = StubEnquiryRepository()
        let viewModel = makeViewModel(repository: repository)

        await viewModel.submit()

        #expect(viewModel.nameError == Constants.Enquiry.nameRequired)
        #expect(viewModel.contactError == Constants.Enquiry.contactRequired)
        #expect(viewModel.messageError == Constants.Enquiry.messageRequired)
        #expect(viewModel.phase == .editing)
        #expect(await repository.log.enquiries.isEmpty)
    }

    @Test func whitespaceOnlyFieldsCountAsEmpty() async {
        let viewModel = makeViewModel()
        viewModel.name = "   "
        viewModel.contact = "  "
        viewModel.message = "\n"

        await viewModel.submit()

        #expect(viewModel.nameError != nil)
        #expect(viewModel.contactError == Constants.Enquiry.contactRequired)
        #expect(viewModel.messageError != nil)
    }

    @Test func invalidContactIsExplained() async {
        let viewModel = makeViewModel()
        fill(viewModel, contact: "12345")

        await viewModel.submit()

        #expect(viewModel.contactError == Constants.Enquiry.contactInvalid)
        #expect(viewModel.nameError == nil)
        #expect(viewModel.phase == .editing)
    }

    @Test func errorsClearLiveOnceFixedAfterAFailedAttempt() async {
        let viewModel = makeViewModel()
        await viewModel.submit()

        viewModel.name = "Jane"

        #expect(viewModel.nameError == nil)
        #expect(viewModel.contactError != nil)
    }

    @Test func firstInvalidFieldFollowsTheFormOrder() {
        let viewModel = makeViewModel()
        #expect(viewModel.firstInvalidField == .name)

        viewModel.name = "Jane"
        #expect(viewModel.firstInvalidField == .contact)

        viewModel.contact = "jane@example.com"
        #expect(viewModel.firstInvalidField == .message)

        viewModel.message = "Hello"
        #expect(viewModel.firstInvalidField == nil)
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

        await viewModel.submit()
        #expect(await repository.log.enquiries.count == 2)
    }

    @Test func ignoresASecondSubmitWhileOneIsInFlight() async throws {
        let repository = StubEnquiryRepository(delay: .milliseconds(100))
        let viewModel = makeViewModel(repository: repository)
        fill(viewModel)

        let first = Task { await viewModel.submit() }
        try await Task.sleep(for: .milliseconds(20))
        await viewModel.submit()
        await first.value

        #expect(await repository.log.enquiries.count == 1)
        #expect(viewModel.phase == .submitted)
    }
}
