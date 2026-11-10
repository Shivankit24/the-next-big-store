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
        static let title = "Categories"
        static let topRated = "Top Rated"
        static let moreProducts = "More Products"
        static let expanded = "Expanded"
        static let collapsed = "Collapsed"
    }
}
