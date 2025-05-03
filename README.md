Pokémon API App

This app is part of my journey into learning Swift, working with APIs, and understanding how data flows through an application. It’s not just a project—it’s a milestone in building something real while learning through trial and error. Some of the code may not be optimal, but every part of it was implemented with purpose and personal effort to understand what’s happening under the hood.

Learning in Progress

Throughout this project, I worked to avoid using any code I didn’t understand. When I hit roadblocks, I researched documentation, dug into examples, and tested different approaches until something clicked. That approach shaped how I handled key decisions in the codebase.

For instance, choosing struct over class came after a lot of reading and testing. In the context of decoding JSON from an API, using struct made sense because it’s lightweight and designed for immutable data, which matches the way Pokémon data is fetched and displayed.

The Decodable protocol was also new to me. It allows Swift to automatically map incoming JSON data into usable structures. Each struct in the app corresponds to part of the API response, and the layout of those structs defines how the app interacts with that data.

App Overview
	•	Users can search for a Pokémon by name and view its stats, sprite, and evolutions.
	•	The app uses SwiftUI and fetches data live from PokéAPI.
	•	Evolution chains are shown in both directions—previous evolutions and possible evolutions are fetched and displayed.
	•	Scroll indicators and a smooth interface make it easy to navigate even with a large amount of content.

Fuzzy Search

One of the more difficult but satisfying features to implement was the fuzzy search.

At first, if you didn’t spell a Pokémon’s name exactly right, the app returned nothing. That wasn’t a great user experience, so I began looking into ways to improve it. I eventually implemented a fuzzy search function based on the Levenshtein distance algorithm, which calculates the difference between two strings.

This was not easy. I didn’t fully understand the algorithm at first and had trouble figuring out how to integrate it with the rest of the app. After experimenting with different logic and a lot of testing, I was able to get the feature working.

Now, the app downloads a full list of Pokémon names at launch. When the user searches, the input is compared against that list using the string distance function to suggest the closest match (for example, “Did you mean Bulbasaur?”). It works well, and it adds a level of polish I’m proud of.

Areas for Improvement

There’s still a lot I’d like to explore and improve in this app:
	•	Caching: Right now, the app makes repeated API calls. Caching results locally could reduce traffic and improve performance.
	•	Security: The API responses are unencrypted plaintext. I’d like to eventually experiment with ways to secure API interactions or at least better understand the risks.
	•	Evolution Logic: Parsing evolution chains, especially for complex trees like Eevee’s, was tough. I’d like to revisit that code and refactor it into something cleaner and more reusable.

Final Thoughts

This app is a hands-on product of trial, error, and persistence. I’ve learned a lot about Swift, JSON decoding, view rendering, and working with external data. More than that, I’ve learned how to stay curious and work through problems that felt too big at first. Every improvement made along the way was hard-won, and I look forward to continuing the journey.
