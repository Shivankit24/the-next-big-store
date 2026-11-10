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

- macOS with **Xcode** (recent release; the project uses folder-synced targets and Swift Testing)
- An **iOS Simulator** (iPhone; deployment target iOS 18.6)
- **Node.js 20.12 or newer** with npm, for the local backend

No third-party iOS dependencies, paid services, accounts or secrets are needed.

## Quick start (about 5 minutes)

The app never calls FakeStoreAPI directly. It talks to a small local Node/TypeScript server that proxies it, so start the server first.

**1. Start the backend**

```sh
cd ios-mock-server
cp .env.example .env     # optional: defaults work without it
npm install
npm start
```

You should see `Proxy server running smoothly at http://localhost:3000`. Leave it running. Check it in a browser or terminal:

```sh
curl http://localhost:3000/products
```

**2. Run the app**

1. Open `TheNextBigStore.xcodeproj` in Xcode.
2. Select the **TheNextBigStore** scheme and any iPhone simulator.
3. Press **Run** (Cmd+R).

The simulator reaches the server at `http://localhost:3000`, which is the app's default (`APIConfiguration.local`). `Info.plist` allows plain HTTP to local addresses for this.

If the app shows an error state instead of products, the server is not running or not reachable (see [Troubleshooting](#troubleshooting)). SwiftUI previews work without the server, using sample data.

## Backend configuration

Settings live in `ios-mock-server/.env`, which is read directly by `server.ts` and is git-ignored. Copy `.env.example` to create it; never commit secrets.

| Variable | Default | Purpose |
| --- | --- | --- |
| `PORT` | `3000` | Port the server listens on |
| `FAKE_STORE_API_BASE_URL` | `https://fakestoreapi.com` | Upstream product API it proxies to |

Real environment variables take precedence over the file, and if there is no `.env` the defaults above are used. If you change `PORT`, update the base URL in `TheNextBigStore/Core/Networking/APIConfiguration.swift` to match.

Endpoints:

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/products` | List all products |
| GET | `/products/:id` | One product (404 if unknown) |

Enquiries are a placeholder in this MVP, so the server has no enquiry endpoint yet (see [DECISIONS.md](DECISIONS.md)).

## Run the tests

Press **Cmd+U** in Xcode, or from a terminal:

```sh
xcodebuild test -scheme TheNextBigStore -destination 'platform=iOS Simulator,name=<simulator name>'
```

Tests use Swift Testing and cover networking, repositories, models, view models and formatters, with stubs instead of the network, so the server is not needed.

## Troubleshooting

| Symptom | Likely cause and fix |
| --- | --- |
| App shows an error / no products | Server not running. Start it with `npm start` in `ios-mock-server` and use the retry action in the app. |
| `npm start` fails with an unknown flag or `loadEnvFile` error | Node is older than 20.12. Upgrade Node. |
| `Address already in use` | Something else uses port 3000. Stop it, or set another `PORT` in `.env` and update `APIConfiguration.swift`. |
| Server runs but products never arrive | The machine cannot reach `fakestoreapi.com`. Check the network, or the `FAKE_STORE_API_BASE_URL` value. |
| `node_modules` errors after copying the project between machines | Delete `ios-mock-server/node_modules` and run `npm install` again. |

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
ios-mock-server/        Local Node/TypeScript proxy to FakeStoreAPI (.env.example, server.ts)
```

Where to change things:

- **Swap the product data source:** only `Data/` changes. DTOs map the wire format to domain models, so screens do not know about FakeStoreAPI. Re-point `AppContainer.productRepository`.
- **Deliver enquiries for real:** in `AppContainer`, replace `PlaceholderEnquiryRepository()` with `RemoteEnquiryRepository`, which posts to `/enquiries`. A different email provider would be another `EnquiryRepository` implementation.
- **Restyle:** colours, spacing and fonts are in `Shared/Theme`; user-facing strings and numbers are in `Utils/Constants.swift`.
- **Hide the search bar on a screen:** one case in `AppTab.showsSearchBar`.

## More documentation

- [DECISIONS.md](DECISIONS.md): assumptions, simplifications, how the design grows, next steps
- [AI_USAGE.md](AI_USAGE.md): how AI was used
- [TIME_SPENT.md](TIME_SPENT.md): time spent

## Conventions

SOLID, DRY and KISS; Apple Human Interface Guidelines; small single-purpose commits on `feature/store_mvp`.

## License

Apache License 2.0, see [LICENSE](LICENSE).
