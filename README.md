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

# TODO
Server:

- [ ] Cache threads
- [ ] Music/PDF/webm handling
- [ ] Command line admin thing
- [ ] Public JSON API (get/post/delete)
- [ ] Make the config file control more things
- [ ] Move all the stuff specific to the Fortress in a local branch
- [ ] Release a v1
- [ ] Analytics?

Client:

- [ ] AJAX posting
- [ ] Updating threads
- [ ] Converting greeting to local time
- [X] Moving the reply box around
