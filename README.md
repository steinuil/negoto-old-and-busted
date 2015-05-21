# Negoto
A shitty imageboard which probably won't have that many features and that nobody will run.

Please don't actually use this yet, unless you know what you're doing.

## To run:
* Install Ruby 2.2.2 and MongoDB
* `gem install sinatra mongo htmlentities thin`
* `mkdir cache public/src public/banners`
  * Put some banners in `public/banners` if you want
* Start `mongod`
* Pray
* Run `reset.rb`
* Run `shuko.rb`

## TODO
- [X] Render the thread pages.
- [ ] Images (kinda) and webbums. I guess ImageMagick and ffmpeg will do.
- [X] Actual support for multiple boards.
  * Board creation a shit. It's completely possible though.
- [ ] Control panel for the mods or whatever.
- [ ] Live updating and sorceries of the sort which will require ECMAscript.
  * Use vanilla javascript as much as possible. None of that jQuery stuff pls.
- [ ] Some other nice markup things
- [ ] Make it so that it won't crash and burn if you don't do everything right.
  * This phase probably has a cooler name that will make you feel smarter when you say it.
- [ ] Make the whole thing not look so half-assed.
- [ ] API (this will be easy as balls seeing as everything is stored in json already)