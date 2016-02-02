#FIXME a drink

require "sinatra"
require "tilt/haml"
require "tilt/sass"

require_relative "lib/somnograph"
require_relative "lib/attachment"
require_relative "lib/format"

set :bind, "0.0.0.0"
set :server, :thin
set :port, 6789

REM.connect adapter: "sqlite", database: "negoto.db"

helpers do
  def elapsed time
    Time.elapsed time
  end
  
  def greeting
    @hour = Time.now.hour
    if @hour < 6 or @hour > 22
      "Good night"
    elsif @hour >= 6 and @hour < 12
      "Good morning"
    elsif @hour >= 12 and @hour < 18
      "Good afternoon"
    else "Good evening" end
  end

  def banner
    Dir.chdir("public") { Dir.glob("banners/*").sample }
  end
end

get "/" do
  @boards = Board.names
  haml :front
end

get "/style.css" do
  sass :style
end

get "/:board_id/" do |board_id|
  @boards = Board.list

  @board_id = board_id
  @board_name = Board[board_id].name
  @thread_id = 0

  @threads = Board[board_id].yarns.all.reverse

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

  @file_info = Attachment.add(params[:file], :op)

  @post = {
    board: board_id,
    subject: params[:subject],
    name: params[:name],
    body: params[:body],
    spoiler: params[:spoiler] == "on" ? true : false,
    file: @file_info.to_s
  }

  Yarn.create @post

  "Post successful"
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

  @file_info = Attachment.add(params[:file], :post) if params[:file]

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
