# Negoto
An imageboard written Ruby using Sinatra and a few other things.

# Requirements
* Ruby (tested in Ruby 2.3.0)
* A database compatible with [Sequel](http://sequel.jeremyevans.net) (tested with SQLite)
* Image/GraphicsMagick
* Gems: `sinatra thin haml sequel mini_magick sass`

# Running
* Create `config.yml` and configure it to your liking
* Put some banners into `public/banners` if you so desire
* Run `start.rb`
* Run `app.rb`

# Resetting
* Run `start.rb reset`

# What works without spewing out walls of errors
* Creating boards
* Running the program
* Rendering the homepage and a page for each board
* Rendering thread pages
* Markup (code blocks, spoilers, quotes)
* API:
  * POST new threads
  * POST new posts
  * GET board list

# Whatnot
* Basically everything else

# Javascript stuff to implement
* AJAX posting
* Updating threads
* Converting dates to local time
* Converting greeting to local time
* Moving the reply box around
