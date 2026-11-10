# AI Usage Notes
## Tools and models used
Claude as a Copilot for everything - Planning, Coding and documentation

## Agent instruction files
_TODO: list any CLAUDE.md, AGENTS.md, .cursor/rules etc. committed to the repo._

## Plan or spec
Planning and project details - ProjectContext.md
API Contract description- api_contract_data_models.md

## Key prompts or moments that shaped the solution (3–5)
1. Ok, so I made some changes locally, nothing major, all good.Now, for screens and assumptions for them. Let's go step by step and start with the Home page.
GIVEN I have chosen 5 products to be "top rated" - Now there's a confusion here as this statement says 'I have chosen 5 products to be "top rated"', but looking at the response, there's a rating parameter, so not sure which one to use. Will go with the rating.rate parameter to list top 5 products to feature. And when 2 products have same rating.rate value, then rating.count will be considered. And if for an edge case, both are same for 2 products, then preference will be given based on alphabetical order.
Next assumption is about the UI/UX - How will the products be displayed, what info will be displayed and what not as we have many things including - title, which is mandatory to be there, hence will use it and will be highlighted
id, which we will use to uniquely identify the items, but not needed in UI price - will be displayed in Australian Dollars, again highlighted
Description - let's use it in the product details page and not here image - Definitely use it
Display order in the page assumption -
The product tiles on the Home and Category pages, both will display the image, title, price, and the rating (likely as a star UI).
2. Mostly good but a few observations - 
I see AsyncImage type is being used to load images, but they load all at once, where I feel that we can leverage async behaviour here and whichever arrives first should be displayed straight away without first waiting for all to be downloaded and displayed at once. Tile UI can be better, I mean don't worry about the colours but just the way tile is created and other aspects like rounded corners and paddings around
3. Let's fix the Home Page UI as now Top Rated title has moved behind the Search bar and only appears when I forcefully scroll down and goes away when the scroll is complete. Also, there's unwanted space above the Search bar, there should be space, but not this much. And as I mentioned it as a global searchI am thinking of having the same search bar, I would like it to be on the window rather than on each view, so that it is initialized once and is stuck at the top of each page and is available all the time. Only caveat will be for the pages that don't need it, like Profile page (in future), hence I want you to have a logic where if I am on a specific page where I don't want to have the Search bar, it is just a 1 line change and it shouldn't impact the other parts of the app.

## Where the AI got something wrong and how it was caught
Multiple times, but the major one was - Images were being downloded and were getting displayed all at once. I checked and AsyncImage was being used which was causing this issue. Hence I rectified this and asked to have a custom implementation of ImageLoader, which displays downloads and loads images as they arrive from the API, rather than waiting for all to download and then display all at once.
