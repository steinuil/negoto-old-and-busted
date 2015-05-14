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
  @banner = Dir.chdir('public') { Dir.glob('banners/*').sample }
  render = ERB.new(File.read("template/#{type}.erb")).result(binding)
  File.write("public/#{id}.html", render)
end

# [insert Frank Sinatra quote here]
get '/' do
  redirect 'index.html'
end

post '/post' do
  @no = params[:thread].to_i
  @info = stats.find(board: "snw").to_a.first.to_h
  @new_post = { no: @info["post_no"] + 1,
                name: params[:name],
                body: escape_body(params[:body]),
                #file: { original: params[:file] },
                time: Time.now }

  if @no == 0
    board.insert_one({ thread: @new_post[:no],
                       op: @new_post,
                       posts: [],
                       updated: Time.now })
    stats.find(board: "snw").update_one("$inc" => { :post_no => 1 })

  elsif board.find(thread: @no).count == 0
    redirect '/error/no_thread'

  else
    board.find(thread: @no)
      .update_one("$push" => { posts: @new_post })
      unless params[:sage] == "on"
        board.find(thread: @no)
          .update_one("$set" => { updated: Time.now })
      end

    stats.find(board: "snw").update_one("$inc" => { :post_no => 1 })
  end

  # Update
  @threads = board.find.sort(updated: -1).to_a
  update_page(@threads, @info, "index", "index")

  @no = @new_post[:no] if @no == 0
  update_page(board.find(thread: @no).to_a.first,
              @info, "thread", "thread/#{@no}")

  redirect "/thread/#{@no}.html"
end

get '/update' do
  @threads = board.find.sort(updated: -1).to_a
  @info = stats.find(board: "snw").to_a.first.to_h

  update_page(@threads, @info, "index", "index")

  @threads.each do |thread|
    update_page(thread, @info, "thread", "thread/#{thread["op"]["no"]}")
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
