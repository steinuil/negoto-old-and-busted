# Negoto
An imageboard written Ruby using Sinatra and a few other things.

# Requirements
* Ruby 2.x (tested in Ruby 2.2 and 2.3)
* A database compatible with [Sequel](http://sequel.jeremyevans.net) (tested in SQLite)
* Image/GraphicsMagick
* Gems: `sinatra thin haml sequel mini_magick sass`

# Running
* Edit `start.rb` to your liking and run it
* Put some banners into `public/banners` if you so desire
* Run `app.rb`

# What works without spewing out walls of errors
* Creating boards
* Running the program
* Rendering the homepage and a page for each board
* Posting new threads
* Rendering thread pages
* Posting in threads

# Whatnot
* Basically everything else

# Javascript stuff to implement
* AJAX posting
* Updating threads
* Converting dates to local time
* Converting greeting to local time
* Moving the reply box around
