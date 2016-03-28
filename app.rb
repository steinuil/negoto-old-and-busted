require "sinatra"
require "tilt/haml"
require "tilt/sass"
require "yaml"

$config = YAML.load(File.read("config.yml"))

DATA_DIR = ""
PUBLIC_DIR = DATA_DIR + "public"

%w[somnograph routes api format].each do |l|
  require_relative "lib/#{l}"
end

configure do
  set :bind, "0.0.0.0"
  set :server, :thin
  set :port, 6789
  set :logging, false # because fuck you
  set :sass, { style: :expanded }
  set :public_folder, PUBLIC_DIR
end

REM.connect adapter: $config[:adapter],
            database: DATA_DIR + $config[:database]

get "/" do
  @type = :front
  haml @type, layout: false
end

get "/*.css" do |type|
  sass type.to_sym
end

get "/*.js" do |name|
  headers "Content-Type" => "application/javascript"
  File.read "views/#{name}.js"
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
