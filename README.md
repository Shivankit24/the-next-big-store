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

## Quick start: run the app step by step (about 10 minutes)

The app shows products that come from a small **local server** (the "mock server") running on your own Mac. So there are two things to start, **in this order**: first the server, then the app. No accounts or payments are needed.

### One-time setup

1. **Install Xcode** from the Mac App Store (free). Open it once so it finishes installing.
2. **Install Node.js** (version 20.12 or newer) from [nodejs.org](https://nodejs.org) using the "LTS" download. To check it worked, open the **Terminal** app (press Cmd+Space, type `Terminal`, press Enter) and run `node -v`. It should print a version such as `v22.x.x`.
3. **Get this project** onto your Mac (clone the repository or download it as a ZIP and unzip it).

### Step 1: start the server

1. In **Terminal**, go into the server folder. Type `cd ` (with a space), drag the `ios-mock-server` folder from Finder into the Terminal window, then press Enter.
2. Run these commands, one at a time, pressing Enter after each:

   ```sh
   cp .env.example .env
   npm install
   npm start
   ```

   - `cp .env.example .env` creates your settings file. You only need to do this once, and the defaults work as they are.
   - `npm install` downloads what the server needs. It takes a minute and only needs to be run the first time.
   - `npm start` starts the server.

3. You know it worked when Terminal says: `Proxy server running smoothly at http://localhost:3000`.
4. **Leave this Terminal window open.** The server only runs while the window is open. Closing it, or pressing Ctrl+C, stops the server.

Optional check: open <http://localhost:3000/products> in a web browser. If you see a long list of products, the server is working.

### Step 2: run the app

1. In Finder, double-click `TheNextBigStore.xcodeproj` to open it in Xcode.
2. At the top of the Xcode window, make sure the scheme says **TheNextBigStore**, and pick any iPhone (for example "iPhone 16") as the device.
3. Press the **Play** button (or Cmd+R). The first build takes a minute, then the iPhone Simulator opens and shows the store.

The app finds the server by itself at `http://localhost:3000`, so there is nothing to type in.

### Stopping and starting again

- To stop: press the **Stop** button in Xcode, and press **Ctrl+C** in the Terminal window running the server.
- To start again later: only repeat Step 1 using `npm start` (skip `cp` and `npm install`), then press Play in Xcode.

If the app shows an error instead of products, the server is not running. Go back to Step 1, then use the retry button in the app. More help is in [Troubleshooting](#troubleshooting). SwiftUI previews in Xcode work without the server, using sample data.

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
| `npm: command not found` or `node: command not found` | Node.js is not installed. Install it from nodejs.org, then reopen Terminal. |
| `npm start` fails with a `loadEnvFile` error | Node is older than 20.12. Upgrade Node. |
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
