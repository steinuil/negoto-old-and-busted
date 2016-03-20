# Negoto
An imageboard written Ruby using Sinatra and a few other things.

# Requirements
* Ruby (tested in Ruby 2.3.0)
* A database compatible with [Sequel](http://sequel.jeremyevans.net) (tested with SQLite)
* Image/GraphicsMagick

# Running
* Install the required gems with `bundle install`
* Create `config.yml` and configure it to your liking
* Put some banners into `public/banners` if you so desire
* Run `start.rb`
* Run `app.rb`

# Administering
* Run `admin.rb`

# Resetting
* Run `start.rb reset`

# Features
This is just a list of ideas that I might want to implement later. Not all of them might make it.

Server:

- [X] Delete files when deleting associated post
- [X] Ban people
- [ ] Cache threads
- [ ] Pin threads
- [ ] /all/ or /recent/ metaboard
- [ ] Music/webm handling
- [X] Admin console
  - [ ] Add more commands (ban, bump, edit…)
  - [ ] Make it work remotely
  - [ ] Accounts (admins, mods, janitors)
- [ ] Report system
- [ ] Public JSON API (get/post/delete)
- [ ] Make the config file control more things
- [ ] News/blotter/whatever
  * Might have to depend on some Markdown library
    * minidown looks like a good candidate
- [ ] Move all the stuff specific to the Fortress in a local branch
- [ ] Release a v1
- [ ] Analytics
  * Could be coupled with the ban system

Client:

- [ ] AJAX posting
- [ ] Auto updating threads
- [X] Converting greeting to local time
- [X] Moving the reply box around
