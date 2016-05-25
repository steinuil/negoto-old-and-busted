# Negoto Mark III

Negoto is an **imageboard**.

It is written in **Ruby**.

It doesn't use ~~Rails~~.

It is pretty **good-looking**, if I may say so myself. (But you can change that if you don't like it.)

It tries to be **simple**.

It doesn't try to be **fast**. (But that doesn't mean it's slow.)

It is quite **small**.

```
>> wc -l *.rb **/*.rb **/**/*.^(rb js haml sass)
    ...
    1644 total
```


This is the third time I've rewritten it, so it's Mark III.

*TL Note: negoto means sleep-talking.*

## Getting it to run

Install these:
* Ruby 2.x (possibly 2.3.x)
* gem (should be bundled with Ruby)
* SQLite
* ImageMagick

Then do these:
1. Run `bundle install` to install the required gems
2. Edit `negoto.rb` (you might need to activate Common Sense 2016 for this)
3. Run `negoto.rb`

You should also have these:
* A `spoiler.jpg` file in the `public/thumb` folder
* A few 300╳100 banners in the `public/crests` folder
* A `public/assets` folder with the following:
  * A `404.jpg` file to show on the error page
  * A `shuko.svg` file to show on the front page
  * A `tile.png` file as front page background

## Actually running it

Run `negoto.rb`. It just werks.

## What it does

All the basic imageboard stuff. It has a front page, a catalog, a thread page, and a readme page. You can post with an image, spoiler, and sage. You can post and get the new posts in a thread without refreshing.

## What it doesn't (yet)

Can't ban the twerps and heathens right now. An admin control panel would be easy but it sounds like a pain in the arse. I swear I'll add it one of these days.

## Other things

If you're thinking about actually using Negoto, I congratulate you for your taste in imageboard software, but I warn you: you're gonna have to edit a lot of things.

Most settings are hardcoded because I'm too lazy to think of a way to store the configuration, so you're gonna have to read the source code.

It's not hard, there's a little more than 1600 lines of it, counting all the files. I think it's mostly understandable. Except the `String.format_post` method. I had fun with that one.

I'm available at [@steinuil](https://twitter.com/steinuil) and email and some other things if you need help setting it up.
