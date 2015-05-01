require 'sinatra'
require 'mongo'
require 'erb'
require 'htmlentities'

# Options
set :bind, '0.0.0.0' # This is so that I can access it over the LAN

$wordfilters = [
  { from: /yeah|yes/i, to: "Jud" },
  { from: /shit/i, to: "Seiya" }
]

# Database stuff
database = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'shuko')
board = database[:snw]
stats = database[:statistics]

# [insert Frank Sinatra quote here]
def escape_body(text)
  $wordfilters.each { |pairs| text = text.gsub(pairs[:from], pairs[:to]) }
  HTMLEntities.new.encode(text).gsub(/\r\n?/, "<br>")
end

get '/' do
  redirect 'index.html'
end

post '/post' do
  @thread = params[:thread].to_i
  if @thread == 0
    board.insert_one({ thread: 0, posts: [] })
  end
  stats.find({ board: params[:board] }).update_one("$inc" => { :post_no => 1 })
  @new_post = { no: stats.find({ board: params[:board] }).to_a[0].to_h["post_no"],
                name: params[:name],
                opts: params[:opts],
                body: escape_body(params[:body]),
                # file: { file: params[:file] },
                time: Time.now }
  board.find({ thread: @thread }).update_one("$push" => { posts: @new_post })
  #if @thread == 0
  #  board.insert_one({ thread: params[:no], posts: [] })
  #  board.find({ thread: params[:no] }).update_one("$push" => { op: @new_post })
  #elsif board.find({ thread: @thread }).count == 0
  #  "error"
  #else
  #  board.find({ thread: params[:no] }).update_one("$push" => { posts: @new_post })
  #end
  redirect '/'
end

get '/update' do
  @info = stats.find({ board: "snw" }).to_a[0].to_h
  if board.find({ thread: 0 }).count > 0
    @posts = board.find({ thread: 0 }).to_a[0]["posts"]
  else @posts = [] end
  render = ERB.new(File.read('template/index.erb'))
  File.write('public/index.html', render.result(binding))
  redirect '/'
end
