require 'sinatra'
require 'mongo'
require 'erb'
require 'htmlentities'

# Options
set :bind, '0.0.0.0' # this is so that I can access it over the LAN

$wordfilters = [
  #{ from: /\s(yeah|yes)/i, to: "Jud" },
  { from: /shit/i, to: "Seiya" }
]

# Database stuff
database = Mongo::Client.new(['127.0.0.1:27017'], :database => 'shuko')
board = database[:snw]
stats = database[:statistics]

# Functions I guess
def escape_body(text)
  $wordfilters.each { |pairs| text = text.gsub(pairs[:from], pairs[:to]) }
  text = HTMLEntities.new.encode(text)
  # terrible mess
  text.gsub!(/(?<!&gt;)(&gt;){2}([0-9]+)/, '<a class="quotelink" href="#\2">\1\1\2</a>') # >>quote links
  text.gsub!(/(https?|ftp|irc):\/\/(\S+(?!&quot;))/, '<a href="\1://\2">\1://\2</a>')    # links
  text.gsub!(/^(&quot;){3}\R+(.+?)\R(&quot;){3}/m, '<pre class="code">\2</pre>')         # code tags
  text.gsub!(/^(&gt;.+?)$/, '<span class="quote">\1</span>')                             # >quotes
  text.gsub!(/(\r\n|\R)/m, "<br>")
  text.gsub!(/<br><\/span>/, "</span>") # because >quotes fuck up with newlines for some reason
  return text
end

def update_page(thread, info, type, id)
  @threads, @info = thread, info
  render = ERB.new(File.read("views/#{type}.erb")).result(binding)
  File.write("cache/#{id}", render)
end

class Post
  def initialize(post, page, board)
    @post = post
    @page = page
    @board = board
  end

  def send
    if @page == 0
      @board.insert_one({ thread: @post[:no], op: @post, posts: [], updated: Time.now })
    else
      @board.find(thread: @page).update_one("$push" => { posts: @post })
    end
  end
end

# [insert Frank Sinatra quote here]
get '/' do
  @info = stats.find(board: "snw").to_a.first.to_h
  @banner = Dir.chdir('public') { Dir.glob('banners/*').sample }
  @content = File.read("cache/top")
  @no = 0
  erb :layout
end

get '/thread/:id' do |id|
  @info = stats.find(board: "snw").to_a.first.to_h
  @banner = Dir.chdir('public') { Dir.glob('banners/*').sample }
  @content = File.read("cache/#{id}")
  @no = id
  erb :layout
end

post '/post' do
  page = params[:thread].to_i
  if board.find(thread: page).count == 0 and page != 0
    redirect '/error/no_thread'
    break
  end

  info = stats.find(board: "snw").to_a.first.to_h
  post_no = info["post_no"] + 1

  Post.new({ no: post_no,
             name: params[:name],
             body: escape_body(params[:body]),
             time: Time.now }, page, board).send

  stats.find(board: "snw").update_one("$inc" => { post_no: 1 })

  unless params[:sage] == "on"
    board.find(thread: page).update_one("$set" => { updated: Time.now })
  end

  threads = board.find.sort(updated: -1).to_a
  update_page(threads, info, "top", "top")

  page = post_no if page == 0
  update_page(board.find(thread: page).to_a.first, info, "thread", page)

  redirect "/thread/#{page}"
end

get '/update' do
  threads = board.find.sort(updated: -1).to_a
  info = stats.find(board: "snw").to_a.first.to_h

  update_page(threads, info, "top", "top")

  threads.each do |thread|
    update_page(thread, info, "thread", thread["thread"])
  end

  redirect '/'
end

get '/error/:err' do
  if params[:err] == "no_thread"
    "No such thread. <a href='/index.html'>Go back</a>"
  end
end

not_found do
  "This is not the page you're searching for. Are you lost?<br><a href='/'>Go back.</a>"
end
