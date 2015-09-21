require 'sinatra'
require 'mongo'
require 'erb'

require_relative 'classes'

# Settings
set :bind, '0.0.0.0' # this is so that I can access it over the LAN
set :server, :thin   # because the default server is too fucking SLOW
set :port, 6789
Mongo::Logger.logger.level = Logger::INFO

# New Forms
negoto = Chan.new(Mongo::Client.new(['127.0.0.1:27017'], database: 'negoto'))

get '/' do
  @boards = negoto.boards
  erb :front
end

get '/:board_id/' do |board_id|
  page(negoto, board_id, 0)
end

get '/:board_id/thread/:thread_id' do |board_id, thread_id|
  page(negoto, board_id, thread_id)
end

post '/post' do
  board = Board.new(negoto, params[:board])

  post_id = board.get_post_number + 1
  page = params[:thread].to_i
  thread_id = page == 0 ? post_id : page

  thread = Dis.new(board, thread_id)
  post = Post.new(thread, post_id)
  now = Time.now

  if not negoto.include?(params[:board])
    redirect '/error/no_board'
    break
  elsif not board.include?(thread_id) and not post.op?
    redirect '/error/no_thread'
    break
  elsif params[:name].empty?
    redirect '/error/no_name'
    break
  elsif params[:file].nil? and post.op?
    redirect '/error/no_image'
    break
  elsif params[:file].nil? and params[:body].empty?
    redirect '/error/no_comment'
    break
  end

  if params[:file].nil?
    file_info = ""
  else
    @file = Picture.new(params[:file], now)
    @file.resize(post)
    file_info = @file.info
  end

  post_content = {
    no: post_id,
    name: params[:name],
    body: format_text(params[:body]),
    file: file_info,
    time: now
  }

  post.create(post_content)

  thread.bump(now) unless params[:sage] == "on"
  board.cache

  redirect "/#{params[:board]}/thread/#{thread_id}##{post_id}"
end

get '/update' do
  negoto.boards.each do |board_id|
    @board = Board.new(negoto, board_id)
    @board.cache
    @board.threads.each do |thread|
      @thread_id = thread['thread']
      Dis.new(@board, @thread_id).cache
    end
  end
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
