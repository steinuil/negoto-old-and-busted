require "sinatra"
require "tilt/haml"
require "tilt/sass"
require "yaml"

%w[somnograph api attachment helpers format cooldown].each do |l|
  require_relative "lib/#{l}"
end

$config = YAML.load(File.read("config.yml"))

set :bind, "0.0.0.0"
set :server, :thin
set :port, 6789

REM.connect adapter: "sqlite", database: "negoto.db"

get "/" do
  haml :front, layout: false
end

get "/style.css" do
  sass :style
end

get "/:board_id/" do |board_id|
  redirect "/error/no_board" unless Board.list.include? board_id
  @board = { id: board_id, name: Board[board_id].name }
  @threads = Board[board_id].yarns.reverse

  haml :catalog
end

get "/:board_id" do |board_id|
  redirect "/#{board_id}/"
end

get "/:board_id/thread/:thread_id" do |board_id, thread_id|
  unless Yarn.list(board_id).include? thread_id.to_i
    redirect "/error/no_thread"
  end
  @board = { id: board_id, name: Board[board_id].name }
  @op = Yarn[board_id, thread_id].get
  @replies = Yarn[board_id, thread_id].posts

  haml :thread
end

get "/error/:err" do |err|
  case err
  when "no_board"
    @err = "No such board"
  when "no_thread"
    @err = "No such thread"
  when "no_subject"
    @err = "You can't start a thread without a subject"
  when "no_image"
    @err = "You can't start a thread without a file"
  when "no_comment"
    @err = "You can't post without both a comment and a picture"
  when "subject_too_long"
    @err = "Your subject is too long"
  when "name_too_long"
    @err = "Your name is too long"
  when "post_too_long"
    @err = "Your post is too long"
  end
  @title = "Error"

  haml :error
end
