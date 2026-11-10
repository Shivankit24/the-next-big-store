
Technical details & constraints
	•	FakeStoreAPI services will be used for this project.
	•	Use the default SwiftUI architecture - MVVM.
	•	Use standard coding principles for reusability, readability, maintainability and scalability, like - SOLID, DRY, KISS and Apple’s HIG.
	•	App won’t call the APIs directly, rather it will be through a backend which I have already built using NodeJS (will need to use the js file to create a local server, keep in mind that this app will be hosted on a Git repository, hence backend local server has to be considered as a deliverable too) - 
	⁃	https://fakestoreapi.com/products
	⁃	https://fakestoreapi.com/products/${productId}
	•	Backend server code is added as a separate file named server.ts.
	•	Create a readme file for the Git repo as well, only once the project is complete. It should contain these:
	⁃	Brief introduction about the project and what it does
	⁃	Setup and usage instructions
	⁃	Prior Configuration like local server setup etc.
	•	If there’s a need to include infrastructure in the project, it must be compatible with AWS.
	•	Solution and hence README.md must be well optimized so that it takes less than 10 minutes for anyone to understand it completely.
	•	App should build and run successfully using iOS Simulator against locally running backend (NodeJS).
	•	Must not commit any secrets like API keys, passwords etc. Create and use an example env file to manage configuration.
	•	Solution must not depend on any paid services or accounts and keep it 100% native, for future OS level adaptation and reusability.
	•	For this project, these are the details for client and server:
	⁃	Client - iOS app using Swift and SwiftUI
	⁃	Server - NodeJS

MVP Screens & other functionality
	•	Home Page
	•	Category Page
	•	Product search Page
	•	Product Enquiry Form

Acceptance criteria

Home page
GIVEN I have chosen 5 products to be "top rated"
WHEN I am viewing the home page
THEN I see those 5 featured products
Category page
GIVEN my products are organised into categories
WHEN I click on a category link
THEN I see top rated products for that category
AND I see additional products in that category

Search
GIVEN I am looking for a specific product
AND I have entered a search term in the search bar
WHEN I click the search button
THEN I only see products that have text matching that search term

Product page
GIVEN I am browsing the products
AND I want to see more details about a specific product
WHEN I click on a product tile
THEN I see the product details page

Enquiry
GIVEN I am viewing a product
AND I am interested in a product
AND I click on the Enquire button
AND I complete the subsequent form with my contact details
WHEN I submit the form
THEN the sales inbox will receive an email
AND the customer will see a "Thank you" message

Unit Testing strategy
	•	Leverage Swift Testing framework to write functional tests

Guidelines for you
	•	In case of confusion/query/concern, don’t assume and work, always ask clarifying questions in such cases
	•	Considering you have a vast knowledge and access, if the context isn’t limited, tokens usage can easily skyrocket. So do 2 things in such case - 
	⁃	if you feel that there’s a limited context, ask for confirmation before going to a deep internet/Model search
	⁃	Cache this project’s knowledge from context and ongoing conversations and always look from there first, before making an internet/Model search. These 2 things will help minimising token consumption.
