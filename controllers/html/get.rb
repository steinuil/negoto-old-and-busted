get '/' do
  haml :front, layout: false, locals: {
    boards: Board.all,
    logo: (File.read("#{PUBLIC}/assets/shuko.svg") rescue nil)
  }
end

get('/thumb/spoiler.jpg') { redirect '/assets/spoiler.jpg' }

get '/*.css' do |type|
  headers 'Content-Type' => 'text/css'
  begin
    sass type.to_sym
  rescue SystemCallError
    halt 404
  end
end

get '/*.js' do |name|
  headers 'Content-Type' => 'application/javascript'
  begin
    File.read "#{settings.views[:js]}/#{name}.js"
  rescue
    halt 404
  end
end

get '/readme' do
  haml :readme, layout: :alt, locals: {
    title: 'Readme',
    boards: Board.all
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
    type: :catalog,
    board: board,
    boards: Board.all,
    yarns: board.yarns.reverse
  }
end

get '/:board' do |board|
  if (Board[board] rescue false)
    redirect "/#{board}/"
  else
    pass
  end
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
    type: :yarn,
    board: board,
    boards: Board.all,
    op: yarn.op,
    posts: yarn.posts,
    url: "/#{board.id}/thread/#{yarn.id}"
  }
end

get '/refresh/:board_id/thread/:yarn_id' do |board_id, yarn_id|
  begin
    yarn = Yarn[board_id, yarn_id]
  rescue BoardNotFound, YarnNotFound => e
    halt 404
  end
  
  yarn.posts.drop_while do |post|
    post[:id] <= params[:last].to_i
  end.map do |post|
    haml :post, layout: false, locals: {
      post: post, url: "/#{yarn.board}/thread/#{yarn.id}"
    }
  end
end
