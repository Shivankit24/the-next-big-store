//
//  EnquiryFormView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// The enquiry form: name, email or Australian phone number, and the enquiry text, all
/// mandatory. Submit stays disabled until the form is valid. Shows a thank-you message once the
/// enquiry has been delivered.
struct EnquiryFormView: View {
    @State private var viewModel: EnquiryViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: EnquiryViewModel.Field?

    init(viewModel: EnquiryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.phase == .submitted {
                    thankYou
                } else {
                    form
                }
            }
            .animation(.snappy(duration: 0.25), value: viewModel.phase == .submitted)
            .navigationTitle(Constants.Enquiry.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.phase != .submitted {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(Constants.Enquiry.cancel) { dismiss() }
                    }
                }
            }
        }
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }

    // MARK: Form

    private var form: some View {
        Form {
            Section {
                LabeledContent {
                    Text(PriceFormatter.string(from: viewModel.product.price))
                        .fontWeight(.semibold)
                } label: {
                    Text(viewModel.product.title)
                        .lineLimit(2)
                }
            }

            Section {
                TextField(Constants.Enquiry.namePlaceholder, text: binding(\.name))
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .name)
                    .onSubmit { focusedField = .contact }
            } header: {
                Text(Constants.Enquiry.nameLabel)
            } footer: {
                errorText(viewModel.nameError)
            }

            Section {
                Picker(Constants.Enquiry.contactLabel, selection: contactMethodBinding) {
                    Text(Constants.Enquiry.emailOption).tag(EnquiryViewModel.ContactMethod.email)
                    Text(Constants.Enquiry.phoneOption).tag(EnquiryViewModel.ContactMethod.phone)
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                contactField
            } header: {
                Text(Constants.Enquiry.contactLabel)
            } footer: {
                errorText(viewModel.contactError)
            }

            Section {
                TextField(Constants.Enquiry.messagePlaceholder, text: binding(\.message), axis: .vertical)
                    .lineLimit(4...8)
                    .focused($focusedField, equals: .message)
            } header: {
                Text(Constants.Enquiry.messageLabel)
            } footer: {
                errorText(viewModel.messageError)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .animation(.snappy(duration: 0.2), value: viewModel.contactMethod)
        .toolbar {
            // A number pad has no return key, so give it a way to close.
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(Constants.Enquiry.done) { focusedField = nil }
            }
        }
        // Leaving a field is what lets its error show.
        .onChange(of: focusedField) { previous, _ in
            if let previous { viewModel.touch(previous) }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { submitBar }
    }

    /// Email mode is a plain address field. Phone mode shows a fixed +61 beside a number-only
    /// field, so the customer only types the 10 digits.
    @ViewBuilder
    private var contactField: some View {
        switch viewModel.contactMethod {
        case .email:
            TextField(Constants.Enquiry.emailPlaceholder, text: contactBinding)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .focused($focusedField, equals: .contact)
                .onSubmit { focusedField = .message }
        case .phone:
            HStack(spacing: Theme.Spacing.s) {
                Text(Constants.Enquiry.countryCode)
                    .foregroundStyle(.secondary)
                TextField(Constants.Enquiry.phonePlaceholder, text: contactBinding)
                    .keyboardType(.numberPad)
                    .textContentType(.telephoneNumber)
                    .focused($focusedField, equals: .contact)
            }
        }
    }

    private var submitBar: some View {
        VStack(spacing: Theme.Spacing.s) {
            if case .failed(let message) = viewModel.phase {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
            Button {
                Task { await viewModel.submit() }
            } label: {
                Group {
                    if viewModel.isSubmitting {
                        ProgressView()
                    } else {
                        Text(Constants.Enquiry.submit)
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.s)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.canSubmit)
        }
        .padding(Theme.Spacing.l)
        .background(.bar)
    }

    // MARK: Thank you

    private var thankYou: some View {
        VStack(spacing: Theme.Spacing.l) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .accessibilityHidden(true)
            Text(Constants.Enquiry.thankYouTitle)
                .font(.title.bold())
            Text(Constants.Enquiry.thankYouMessage(productTitle: viewModel.product.title))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                dismiss()
            } label: {
                Text(Constants.Enquiry.done)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.s)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(Theme.Spacing.l)
        .transition(.opacity)
    }

    // MARK: Helpers

    private var contactBinding: Binding<String> {
        Binding(get: { viewModel.contact }, set: { viewModel.updateContact($0) })
    }

    private var contactMethodBinding: Binding<EnquiryViewModel.ContactMethod> {
        Binding(get: { viewModel.contactMethod }, set: { viewModel.selectContactMethod($0) })
    }

    private func binding(_ keyPath: ReferenceWritableKeyPath<EnquiryViewModel, String>) -> Binding<String> {
        Binding(
            get: { viewModel[keyPath: keyPath] },
            set: { viewModel[keyPath: keyPath] = $0 }
        )
    }

    @ViewBuilder
    private func errorText(_ message: String?) -> some View {
        if let message {
            Text(message)
                .foregroundStyle(.red)
        }
    }
}

#if DEBUG
#Preview {
    EnquiryFormView(
        viewModel: EnquiryViewModel(product: PreviewData.products[0], repository: PreviewEnquiryRepository())
    )
}
#endif
