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
database = Mongo::Client.new(['127.0.0.1:27017'], :database => 'shuko')
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

get '/error/:err' do
  if params[:err] == "no_thread"
    "No such thread. <a href='/index.html'>Go back</a>"
  end
end

post '/post' do
  @thread_no = params[:thread].to_i
  @info = stats.find({ board: "snw" }).to_a[0].to_h
  @new_post = { no: @info["post_no"] + 1,
                name: params[:name],
                #opts: params[:opts],
                body: escape_body(params[:body]),
                #file: { original: params[:file] },
                time: Time.now }

  if @thread_no == 0
    board.insert_one({ thread: @new_post[:no],
                       posts: [],
                       op: @new_post,
                       updated: Time.now })
    #board.find({ thread: @new_post[:no] })
    #  .update_one( "$set" => { op: @new_post,
    #                           updated: Time.now})
    stats.find({ board: "snw" }).update_one("$inc" => { :post_no => 1 })

  elsif board.find({ thread: @thread_no }).count == 0
    redirect '/error/no_thread'

  else
    board.find({ thread: @thread_no })
      .update_one("$push" => { posts: @new_post },
                  "$set" => { updated: Time.now })
    stats.find({ board: "snw" }).update_one("$inc" => { :post_no => 1 })
  end

  # Update
  @thread = board.find.sort(updated: -1).to_a
  render = ERB.new(File.read('template/index.erb'))
  File.write('public/index.html', render.result(binding))

  redirect '/'
end

get '/update' do
  @info = stats.find({ board: "snw" }).to_a[0].to_h
  @thread = board.find.sort(updated: -1).to_a
  render = ERB.new(File.read('template/index.erb'))
  File.write('public/index.html', render.result(binding))
  redirect '/'
end
