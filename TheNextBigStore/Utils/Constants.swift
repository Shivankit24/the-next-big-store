//
//  Constants.swift
//  TheNextBigStore
//
//  Created by Shivankit on 09/11/26.
//

import Foundation

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
        static let emailRequired = "Please enter your email address."
        static let emailInvalid = "Enter a valid email address."
        static let phoneRequired = "Please enter your phone number."
        static let phoneInvalid = "Enter a 10-digit Australian phone number, e.g. 0412 345 678."
        static let messageRequired = "Please tell us what you would like to know."
        static let title = "Enquiry"
        static let cancel = "Cancel"
        static let nameLabel = "Name"
        static let namePlaceholder = "Your full name"
        static let contactLabel = "How can we reach you?"
        static let emailOption = "Email"
        static let phoneOption = "Phone"
        static let emailPlaceholder = "name@example.com"
        static let phonePlaceholder = "0412 345 678"
        static let countryCode = "+61"
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
