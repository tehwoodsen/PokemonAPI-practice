While I am on a journey to learn and understand coding better, some of these may not end up being super coherent but might be more of a stream of conciousness READ ME

Creating this code, I wanted to make clear that while an LLM is helping me, I have to stress that I am doing my best to not implement anything that I dont understand. For instance:

I had a lengthy discussion about why the use of struct vs any other class in this project and it has to do with how the app is pulling in data. Other APIs may use other classes in other instacnes.

The way it was described is that the decodable library helps pull in external data -and in this instance- JSON data into readable formats and the struct helps conform the data into readable 
entries to interact with. That sounds redundant but I think both of those statements are needed to be true. 

Each struct is pulling the JSON data and interacting with it to display how I have defined it

The var section has a complex call that I had trouble working into the code but i felt strangely passionate about getting into the project, so i did have help massaging it into the code.

  I for the life of me couldnt figure out the spelling of a pokemon and the app would not work without the exact name. 
    I found a fuzzylogic search function on google and tried to understand it. 
        I could not
    Now, I presented my find to 4o-high and it had the documentation to help with exactly how it worked and what to do with it. I initially refused its help and tried to get the references to work proper. 
      The start of anyone's journey is one step at a time, and couldnt get it to work. I decided to see how where and why it connected the logic to the search function. It is still beyond me hahaha
      BUT, I got the fuzzy search into the simple app, and it did exactly what I wanted. 

  What I can tell you about the search fuzzy search is that it has to download an entire reference file of all pokemon names (just names) on loading of the app. 
  And then runs a fancy logic diff function called levenshtein that calculates numeric distance between strings entered and whats stored in the initial array and uses that to create the "Did you mean XXXX". 
  From what I can tell it works reeeeally well and levenshtein is BUILT INTO the swift library, I think its something Apple implements into OS searches possibly? Eh who knows. 
      
      
  Things that I know can be done better: find a way to store the information to prevent too many calls to the API, prevents excess traffic, speeds up loading of the app if the initial pull is the only time it has to be done rather than each time. 
  I think I also want to do something security minded, or an API pull with encryption in mind as everything this API does is plain text.       
