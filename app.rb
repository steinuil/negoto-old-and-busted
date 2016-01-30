#FIXME a drink

require "sinatra"
require "haml"

require_relative "lib/somnograph"

set :bind, "0.0.0.0"
set :server, :thin
set :port, 6789

REM.connect adapter: "sqlite", database: "negoto.db"

get "/" do
  @boards = Board.list
  haml :front
end

get "/:board_id/" do |board_id|
  @boards = Board.list
  @banner = Dir.chdir("public") { Dir.glob("banners/*").sample }

  @board_id = board_id
  @board_name = Board[board_id].name
  @thread_id = 0

  @threads = Board[board_id].yarns.all

  haml :base
end

get "/:board_id" do |board_id|
  redirect "/#{board_id}/"
end

get "/:board_id/thread/:thread_id" do |board_id, thread_id|
  # thread info
  haml :page
end

get "/error/:err" do |err|
  case err
  when "no_board"
    error = "No such board"
  end
end

# API
get "/api" do
  "You shouldn't be here."
end

post "/api/:board_id" do |board_id|
  Yarn.create post_content
end

post "/api/:board_id/:thread_id" do |board_id, thread_id|

  post_content = {
    name: params[:name],
    file: file_info
  }

  post = Post.create 
end
