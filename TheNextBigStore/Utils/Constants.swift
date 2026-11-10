//
//  Constants.swift
//  TheNextBigStore
//
//  Created by Shivankit on 09/11/26.
//

nonisolated struct Constants {
    struct NetworkErrors {
        static let invalidURL = "The request could not be created."
        static let appearsOffline = "You appear to be offline. Check your connection and try again."
        static let unableToReachServer = "We couldn't reach the server. Please try again."
        static let unexpectedResponse = "We received an unexpected response from the server."
        static let badStatus = "The server responded with an error "
    }

    nonisolated struct Catalogue {
        static let featuredCount = 5
        static let topRatedPerCategory = 5
    }

    nonisolated struct Currency {
        static let code = "AUD"
        static let localeIdentifier = "en_AU"
    }

    nonisolated struct Rating {
        static let maxStars = 5
    }

    nonisolated struct Home {
        static let title = "Top Rated"
        static let errorTitle = "Something went wrong"
        static let retry = "Try Again"
    }

    nonisolated struct Category {
        static let topRated = "Top Rated"
        static let moreProducts = "More Products"
    }

    nonisolated struct Tabs {
        static let home = "Home"
        static let categories = "Categories"
    }

    nonisolated struct Search {
        static let placeholder = "Search products"
        static let clearLabel = "Clear search"
        static let searchLabel = "Search"
        static let cancel = "Cancel"
        static func resultsTitle(count: Int, query: String) -> String {
            count == 1 ? "1 result for “\(query)”" : "\(count) results for “\(query)”"
        }
    }

    nonisolated struct Enquiry {
        static let nameRequired = "Please enter your name."
        static let contactRequired = "Please enter an email address or phone number."
        static let contactInvalid = "Enter a valid email address or Australian phone number."
        static let messageRequired = "Please tell us what you would like to know."
        static let title = "Enquiry"
        static let cancel = "Cancel"
        static let nameLabel = "Name"
        static let namePlaceholder = "Your full name"
        static let contactLabel = "Email or phone"
        static let contactPlaceholder = "Email or Australian phone number"
        static let messageLabel = "Your enquiry"
        static let messagePlaceholder = "What would you like to know?"
        static let submit = "Submit"
        static let thankYouTitle = "Thank you!"
        static let done = "Done"
        static func thankYouMessage(productTitle: String) -> String {
            "We have received your enquiry about \(productTitle). Our team will be in touch soon."
        }
    }

    nonisolated struct ProductDetails {
        static let description = "Description"
        static let enquire = "Enquire"
        static func ratingValue(_ rate: Double) -> String {
            "\(rate.formatted(.number.precision(.fractionLength(1)))) out of \(Constants.Rating.maxStars)"
        }
    }
}
