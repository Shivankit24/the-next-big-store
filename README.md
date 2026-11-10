# The Next Big Store

A native iOS product catalogue (MVP) for an online store. Customers browse top-rated products, explore categories, search the whole catalogue and send an enquiry about a product they want.

It is built as a foundation rather than a throwaway prototype: the data source, look and feel and enquiry delivery are all expected to change, so each one sits behind a small seam (see [Architecture](#architecture)).

## Features

| Screen | What it does |
| --- | --- |
| **Home** | Top 5 products, ranked by rating, then rating count, then title A–Z |
| **Categories** | Chip bar to switch category; top 5 per category, then "More Products" |
| **Search** | Global search bar on every tab; runs on the trailing search button, matches all words across title, description and category |
| **Product details** | Image, price (AUD), rating, full description and a highlighted **Enquire** button |
| **Enquiry form** | Name, email *or* Australian phone (fixed +61, 10 digits), message. All fields mandatory; Submit stays disabled until valid |

> Enquiries are a placeholder in this MVP: a successful submit goes nowhere (`PlaceholderEnquiryRepository`).

## Requirements

- macOS with **Xcode** (the project uses folder-synced targets and Swift Testing, so use a recent release)
- An **iOS Simulator** (iPhone; app deployment target is iOS 18.6)
- **Node.js** to run the local backend (see [Backend](#backend))

No third-party dependencies, paid services or secrets are needed.

## Run the app

1. Open `TheNextBigStore.xcodeproj` in Xcode.
2. Select the **TheNextBigStore** scheme and an iPhone simulator.
3. Start the backend (below), then press **Run** (Cmd+R).

SwiftUI previews work without a backend, using sample data.

## Run the tests

Press **Cmd+U** in Xcode, or from a terminal:

```sh
xcodebuild test -scheme TheNextBigStore -destination 'platform=iOS Simulator,name=<simulator name>'
```

Tests use Swift Testing and cover networking, repositories, models, view models and formatters, using stubs instead of the network.

## Backend

The app never calls FakeStoreAPI directly. It talks to a local Node/TypeScript server (`server.ts`) that proxies it. The base URL is `http://localhost:3000` (`APIConfiguration.local`), and `Info.plist` allows local HTTP via `NSAllowsLocalNetworking`.

The app expects:

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/products` | List all products |
| GET | `/products/{id}` | One product |
| POST | `/enquiries` | Only used once `RemoteEnquiryRepository` is switched on |

> **Status:** the server, its `package.json` and the example env file (`.env.example`) are not in the repository yet. Until they are added, the app launches into its error state. This section will gain the exact start commands when they land.

## Architecture

SwiftUI + MVVM (`@Observable` view models), with dependencies wired in one place.

```
TheNextBigStore/
├── App/        Composition root (AppContainer), RootView, tabs
├── Core/       Networking (HTTPClient, Endpoint), image loading, LoadState
├── Domain/     API-independent models and repository protocols
├── Data/       DTOs, endpoints, remote / cached / placeholder repositories
├── Features/   Home, Category, Search, ProductDetails, Enquiry
├── Shared/     Reusable components and theme
└── Utils/      Constants, formatters
TheNextBigStoreTests/   Mirrors the source tree, with stubs in Support/
```

Where to change things:

- **Swap the product data source:** only `Data/` changes. DTOs map the wire format to domain models, so screens do not know about FakeStoreAPI. Re-point `AppContainer.productRepository`.
- **Deliver enquiries for real:** in `AppContainer`, replace `PlaceholderEnquiryRepository()` with `RemoteEnquiryRepository`, which posts to `/enquiries`. A different email provider would be another `EnquiryRepository` implementation.
- **Restyle:** colours, spacing and fonts are in `Shared/Theme`; user-facing strings and numbers are in `Utils/Constants.swift`.
- **Hide the search bar on a screen:** one case in `AppTab.showsSearchBar`.

## Conventions

SOLID, DRY and KISS; Apple Human Interface Guidelines; small single-purpose commits on `feature/store_mvp`.

## License

Apache License 2.0, see [LICENSE](LICENSE).
