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

  haml :catalog
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
  @err = if not Board.list.include? board_id
    "no_board"
  elsif params[:name].empty?
    "no_name"
  elsif params[:file].nil?
    "no_image"
  end

  redirect "/error/#{@err}" if @err ||= nil

  @file_info = Picture.add(params[:file])

  @post = {
    board: board_id,
    subject: params[:subject],
    name: params[:name],
    body: params[:body],
    spoiler: params[:spoiler] == "on" ? true : false,
    file: @file_info
  }

  Yarn.create post_content
end

post "/api/:board_id/:thread_id" do |board_id, thread_id|
  @err = if not Board.list.include? board_id
    "no_board"
  elsif not Board[board_id].include? thread_id
    "no_thread"
  elsif params[:name].empty?
    "no_name"
  elsif params[:file].nil? and params[:body].empty?
    "no_comment"
  end

  redirect "/error/#{@err}" if @err ||= nil

  @file_info = Picture.add(params[:file]) if params[:file]

  @post = {
    board: board_id,
    yarn: thread_id,
    name: params[:name],
    body: params[:body],
    spoiler: params[:spoiler] == "on" ? true : false,
    sage: params[:sage] == "on" ? true : false,
    file: @file_info ||= ""
  }

  post = Post.create @post

  redirect "/#{board_id}/thread/#{thread_id}#p#{post.id}"
end
