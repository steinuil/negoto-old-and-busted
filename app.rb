require "sinatra"
require "tilt/haml"
require "tilt/sass"
require "yaml"

$config = YAML.load(File.read("config.yml"))

%w[somnograph api attachment helpers format].each do |l|
  require_relative "lib/#{l}"
end

set :bind, "0.0.0.0"
set :server, :thin
set :port, 6789
set :logging, false

REM.connect adapter: "sqlite", database: "negoto.db"

get "/" do
  @type = :front
  haml @type, layout: false
end

get "/*.css" do |type|
  sass type.to_sym
end

get "/about" do
  @title = "About"

  @type = :about
  haml @type
end

get "/:board_id/" do |board_id|
  halt 404 unless Board.ids.include? board_id
  @board = { id: board_id, name: Board[board_id].name }
  @threads = Board[board_id].yarns.reverse

  @type = :catalog
  haml @type
end

get "/:board_id" do |board_id|
  redirect "/#{board_id}/"
end

get "/:board_id/thread/:thread_id" do |board_id, thread_id|
  unless Board[board_id].yarn_ids.include? thread_id.to_i
    halt 404
  end
  @board = { id: board_id, name: Board[board_id].name }
  @op = Yarn[board_id, thread_id].to_hash
  @replies = Yarn[board_id, thread_id].posts

  @type = :thread
  haml @type
end

not_found do
  @err = "404 not found"
  @title = "Error"

  @type = :error
  haml @type
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
  when "cooldown"
    @err = "You must wait 15 seconds before posting again"
  end
  @title = "Error"

  @type = :error
  haml @type
end
