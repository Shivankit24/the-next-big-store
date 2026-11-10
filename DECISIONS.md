# Decisions and Assumptions

How the PoC was shaped, what was assumed where the acceptance criteria were open, what was simplified, and where it goes next. Written during development; items marked **(confirm)** are for the owner to verify or extend.

## 1. Assumptions where the acceptance criteria were unclear

### Home
- **"5 chosen top-rated products"** has no source of truth in FakeStoreAPI, so "top rated" is computed: highest `rating.rate`, ties broken by `rating.count`, then title A–Z, then id (so the order is always deterministic).
- Tiles show image, title, price and a star rating. The id is never shown; the description appears only on the details page.
- Prices are shown in **Australian dollars** (`en_AU`). FakeStoreAPI prices are treated as AUD amounts, with no currency conversion.

### Categories
- Categories are derived from the product data, listed alphabetically.
- Navigation is a **chip bar** with exactly one category always selected (first one by default). An expanding-rows layout was tried on paper and dropped for UX reasons: a permanently open row made collapse/expand behave oddly.
- Each category shows its **top 5** (same ranking rule as Home), then a visually separate **"More Products"** section for the rest.
- Home and Categories are tabs in a tab bar.

### Search
- **Global search**, not per-screen: one search bar lives at the window level above the tab view, so it is created once and is available on every tab.
- Tapping the bar opens a blank search page with the keyboard focused, a clear button inside the field (only when there is text) and a Cancel button beside it that leaves the search flow.
- **Results appear only when the user taps the trailing search button** (or the keyboard's search key), never while typing, as the acceptance criteria say. The search icon and the clear button are visually distinct so they cannot be confused.
- Matching: every word typed must match somewhere in title, description or category name; case and diacritics are ignored. Title matches are listed first.
- Search runs in the app over the cached product list, since FakeStoreAPI has no search endpoint.
- Per-tab control: `AppTab.showsSearchBar` decides where the bar shows, so a future page without search (e.g. Profile) is a one-line change.
- Page titles are not sticky, because the search bar is already the one sticky element.

### Product details and enquiry
- The details page shows everything the API provides, with a prominent Enquire button pinned at the bottom.
- The form collects **name, contact (email or phone), message**. All three are mandatory.
- Phone numbers are **Australian**: the +61 prefix is fixed in the UI and the customer types only 10 digits; the app sends `+61…`. Pasted or formatted input is sanitised to digits.
- Validation is **never triggered by the Submit tap**: Submit stays disabled until the form is valid, and field errors only appear after the user has left that field.
- The "Thank you" confirmation is shown on a successful submit.

### Backend
- The app never calls FakeStoreAPI directly; it talks to a small NodeJS/TypeScript proxy (`ios-mock-server`) on `http://localhost:3000`, as required. Port and upstream URL come from `.env` (see `.env.example`).
- The proxy only forwards `GET /products` and `GET /products/:id`; it does not reshape data.

## 2. Requirements dropped or simplified

| Requirement | What the PoC does | Why |
| --- | --- | --- |
| Enquiry **email to the sales inbox** | Submit validates and shows the thank-you message, but nothing is sent (`PlaceholderEnquiryRepository`). | Owner decision: enquiries are a placeholder for the MVP; the email provider is expected to change and no paid service is allowed. |
| Persistence / offline | Product list cached in memory only, for the app session. | PoC scope; failed loads are never cached, so retry always works. |
| Authentication, accounts, cart, checkout | Not built. | Outside the stated MVP screens. |
| Server-side search, filtering, pagination | Not built; the full list (small) is loaded once. | FakeStoreAPI is tiny and has no such endpoints. |
| iPad, landscape polish, localisation | iPhone only, AUD/English only. | Not requested; creative direction is still coming. |
| CI/CD, deployment, infrastructure | Not included. | Owned by the repository owner; no infrastructure is needed to run the PoC (any future infra must be AWS-compatible). |
| Final look and feel | Neutral theme in one place. | Creative work is still in progress. |

## 3. How the design supports growth beyond the PoC

- **Layers with one-way dependencies:** `Features → Domain ← Data`, with `Core` for networking and images. Screens know nothing about HTTP or JSON.
- **Domain models are independent of the API.** `ProductDTO` and `EnquiryRequestDTO` mirror the wire format and map into `Product`, `ProductCategory` and `Enquiry`. A real catalogue API with different fields changes the DTOs and mapping only.
- **Repositories behind protocols** (`ProductRepository`, `EnquiryRepository`). Swapping the data source or the email provider is a new implementation plus one line in `AppContainer`, the single composition root.
- **Caching is a decorator** (`CachedProductRepository`) so it can be replaced or removed without touching callers. It shares in-flight downloads and does not cache errors.
- **Enquiry delivery is ready to switch on:** `RemoteEnquiryRepository` (`POST /enquiries`) exists; the placeholder is swapped out in `AppContainer`.
- **Look and feel is isolated** in `Shared/Theme` and reusable components; strings and numbers live in `Utils/Constants.swift`.
- **Business rules are pure and tested:** top-rated ranking, search matching, contact validation and formatting have Swift Testing coverage using stubs, with no network needed.
- **Environment configuration:** the app's base URL is one value (`APIConfiguration`), and the server reads `.env`, so moving to a hosted backend needs no code changes elsewhere.
- **MVVM with `@Observable` view models**, created by factories in the container, so features can be tested and previewed independently.
