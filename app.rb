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

  def boards() Board.names end
end

get "/" do
  haml :front, layout: false
end

get "/style.css" do
  sass :style
end

get "/:board_id/" do |board_id|
  @board = { id: board_id, name: Board[board_id].name }
  @threads = Board[board_id].yarns.all.reverse

  haml :catalog
end

get "/:board_id" do |board_id|
  redirect "/#{board_id}/"
end

get "/:board_id/thread/:thread_id" do |board_id, thread_id|
  @board = { id: board_id, name: Board[board_id].name }
  @op = Yarn[board_id, thread_id].get
  @replies = Yarn[board_id, thread_id].posts
  haml :thread
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
  elsif params[:subject].empty?
    "no_subject"
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
    file: @file_info.to_s }

  Yarn.create @post

  "Post successful"
end

post "/api/:board_id/thread/:thread_id" do |board_id, thread_id|
  @err = if not Board.list.include? board_id
    "no_board"
  elsif not Board[board_id].list.include? thread_id.to_i
    "no_thread"
  elsif params[:name].empty?
    "no_name"
  elsif params[:file].nil? and params[:body].empty?
    "no_comment"
  end

  redirect "/error/#{@err}" if @err

  @file_info = Attachment.add(params[:file], :post) if params[:file]

  @post = {
    board: board_id,
    yarn: thread_id,
    name: params[:name],
    body: params[:body],
    spoiler: params[:spoiler] == "on" ? true : false,
    sage: params[:sage] == "on" ? true : false,
    file: @file_info.to_s ||= "" }

  post = Post.create @post

  redirect "/#{board_id}/thread/#{thread_id}#p#{post.id}"
end

get "/api/:board_id/thread/:thread_id/bump" do |board_id, thread_id|
  Yarn[board_id, thread_id].bump
end
