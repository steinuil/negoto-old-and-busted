require 'sinatra'
require 'mongo'
require 'erb'
require 'tilt/erubis'
require 'htmlentities'

# Options
set :bind, '0.0.0.0' # this is so that I can access it over the LAN
set :server, :thin   # because the default server is too fucking SLOW

$wordfilters = [
  #{ from: /\s(yeah|yes)/i, to: "Jud" },
  { from: /shit/i, to: "Seiya" }
]

# Database stuff
database = Mongo::Client.new(['127.0.0.1:27017'], :database => 'negoto')
info = database[:info]

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

def cache(threads, info, type, id, board)
  @threads, @info = threads, info
  @board_id = info['board']
  render = ERB.new(File.read("views/#{type}.erb")).result(binding)
  File.write("cache/#{@board_id}/#{id}", render)
end

#def cache(threads, info, id)
#  update = ->(thread, info, type, id) do
#    @threads, @info = thread, info
#    render = ERB.new(File.read("views/#{type}.erb")).result(binding)
#    File.write("cache/#{id}", render)
#  end
#  threads.each { |thread| update.call(thread, info, "thread", id) }
#  update.call(thread, info, "top", "top")
#end

class Post
  def initialize(post_no, page, board)
    @no = post_no
    @page = page
    @board = board
  end

  def send(content)
    if @page == 0
      @board.insert_one({ thread: @no, op: content, posts: [], updated: Time.now })
    else
      @board.find(thread: @page).update_one("$push" => { posts: content })
    end
  end

  def delete
    @board.find(thread: @page).update_one("$pull" => { posts: { no: @no } })
  end
end

def get_extension(mimetype)
  case mimetype
  when "image/jpeg"
    return ".jpg"
  when "image/png"
    return ".png"
  when "image/gif"
    return ".gif"
  when "video/webm"
    return ".webm"
  end
 end

# [insert Frank Sinatra quote here]
get '/' do
  database.database.collection_names
  #@info = stats.find(board: "snw").to_a.first.to_h
  #@banner = Dir.chdir('public') { Dir.glob('banners/*').sample }
  #@content = File.read("cache/top")
  #@no = 0
  #erb :layout
end

get '/:board/' do |board|
  @info = info.find(board: board).to_a.first.to_h
  @banner = Dir.chdir('public') { Dir.glob('banners/*').sample }
  @content = File.read("cache/#{board}/top")
  @no = 0
  erb :layout
end

get '/:board/thread/:id' do |board, id|
  @info = info.find(board: board).to_a.first.to_h
  @banner = Dir.chdir('public') { Dir.glob('banners/*').sample }
  @content = File.read("cache/#{board}/#{id}")
  @no = id
  erb :layout
end

post '/post' do
  board_id = params[:board]
  board = database[board_id]
  page = params[:thread].to_i
  op = page == 0

  if not info.find(t: 'list').to_a.first.to_h['boards'].include?(board_id)
  #if not database.database.collection_names.include?(board_id) and board_id != "info"
    redirect '/error/no_board'
    break
  elsif board.find(thread: page).count == 0 and not op
    redirect '/error/no_thread'
    break
  elsif params[:name].empty?
    redirect '/error/no_name'
    break
  elsif params[:file].nil? and op
    redirect '/error/no_image'
    break
  elsif params[:file].nil? and params[:body].empty?
    redirect '/error/no_comment'
    break
  end

  if params[:file].nil?
    file_info = ""
  else
    file = params[:file]
    filename = Time.now.to_i.to_s + get_extension(file[:type])
    File.open("public/src/#{filename}", 'wb') { |f| f.write(file[:tempfile].read) }
    file_info = { src: filename, filename: file[:filename] }
  end

  board_info = info.find(board: board_id).to_a.first.to_h
  post_no = board_info["post_no"] + 1

  Post.new(post_no, page, board)
    .send({ no: post_no,
            name: params[:name],
            body: escape_body(params[:body]),
            file: file_info,
            time: Time.now })

  info.find(board: board_id).update_one("$inc" => { post_no: 1 })

  unless params[:sage] == "on"
    board.find(thread: page).update_one("$set" => { updated: Time.now })
  end

  threads = board.find.sort(updated: -1).to_a
  page = post_no if op
  cache(threads, board_info, "top", "top", board)
  cache(board.find(thread: page).to_a.first, board_info, "thread", page, board)

  redirect "#{board_id}/thread/#{page}##{post_no}"
end

get '/update' do
  boards = info.find(t: 'list').to_a.first.to_h['boards']
  boards.each do |board_id|
    board = database[board_id]
    threads = board.find.sort(updated: -1).to_a
    board_info = info.find(board: board_id).to_a.first.to_h
    cache(threads, board_info, "top", "top", board)
    threads.each { |thread| cache(thread, board_info, "thread", thread["thread"], board) }
  end
  #threads = board.find.sort(updated: -1).to_a
  #board_info = stats.find(board: "snw").to_a.first.to_h
  #cache(threads, board_info, "top", "top")
  #threads.each { |thread| cache(thread, board_info, "thread", thread["thread"]) }

  redirect '/'
end

get '/error/:err' do
  case params[:err]
  when "no_board"
    error = "No such board."
  when "no_thread"
    error = "No such thread."
  when "no_image"
    error = "You can't start a thread without an image."
  when "no_comment"
    error = "You can't post without a comment or an image."
  when "no_name"
    error = "You can't post without a name."
  end
  error += " <a href='/'>Get back to where you once belonged.</a>"
  error
end

not_found do
  "This is not the page you're searching for. Are you lost?<br><a href='/'>Go back.</a>"
end
