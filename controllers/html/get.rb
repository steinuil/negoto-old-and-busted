get '/' do
  haml :front, layout: false, locals: {
    boards: Board.all
  }
end

get '/*.css' do |type|
  headers 'Content-Type' => 'text/css'
end

get '/*.js' do |name|
  headers 'Content-Type' => 'application/javascript'
end

get '/about' do
  haml :about, locals: {
    title: 'About',
  }
end

get '/:board_id/' do |board_id|
  begin
    board = Board[board_id]
  rescue BoardNotFound => e
    halt 404
  end

  haml :catalog, locals: {
    title: "/#{board.id}/ - #{board.name}",
    board: board,
    boards: Board.all,
    yarns: board.yarns
  }
end

get '/:board' do |board|
  redirect "/#{board}/"
end

get '/:board_id/thread/:yarn_id' do |board_id, yarn_id|
  begin
    board = Board[board_id]
    yarn = Yarn[board_id, yarn_id]
  rescue BoardNotFound, YarnNotFound => e
    halt 404
  end

  haml :yarn, locals: {
    title: "/#{board.id}/ - #{board.name}",
    board: board,
    boards: Board.all,
    op: yarn.op,
    posts: yarn.posts,
    url: "/#{board.id}/thread/#{yarn.op[:id]}"
  }
end
