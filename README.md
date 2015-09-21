# Negoto
A shitty imageboard which probably won't have that many features and that nobody will run.

Please don't actually use this yet, unless you know what you're doing.

## To run:
* Install Ruby 2.2.2, MongoDB and ImageMagick
* `gem install sinatra mongo htmlentities thin rouge mini_magick`
* `mkdir cache public/src public/thumb public/banners`
  * Put some banners in `public/banners` if you want
* Start `mongod`
* Pray
* Run `reset.rb start`
* Run `shuko.rb`

## TODO
- [X] Render the thread pages.
- [X] Images.
  - [X] Thumbnails for said images.
- [ ] Webbums, PDF and whatnot.
- [X] Actual support for multiple boards.
  * Board creation a shit. It's completely possible though.
- [ ] Control panel for the mods or whatever.
- [ ] Live updating and sorceries of the sort which will require js.
  * Use vanilla javascript. You don't need jQuery.
- [ ] Some other nice markup things
- [ ] Make it so that it won't crash and burn if you don't do everything right.
  * This phase probably has a cooler name that will make you feel smarter when you say it.
- [ ] Make the whole thing not look so half-assed.
- [ ] API (this will be easy as balls seeing as everything is stored in json already)
