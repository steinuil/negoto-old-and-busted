get "/" do
  haml @type = :front, layout: false
end

get "/*.css" do |type|
  headers "Content-Type" => "text/css"
  sass type.to_sym
end

get "/*.js" do |name|
  headers "Content-Type" => "application/javascript"
  File.read "views/#{name}.js"
end

get "/about" do
  @title = "About"
  haml @type = :about
end

get "/:board/" do |board|
  halt 404 unless Board.ids.include? board
  @board = { id: board, name: Board[board].name }
  @threads = Board[board].to_hash.reverse
  haml @type = :catalog
end

get "/:board" do |board|
  redirect "/#{board}/"
end

get "/:board/thread/:thread" do |board, thread|
  halt 404 unless Board[board].yarn_ids.include? thread.to_i
  @board = { id: board, name: Board[board].name }
  @op = Yarn[board, thread].to_hash
  @replies = Yarn[board, thread].posts
  haml @type = :thread
end
