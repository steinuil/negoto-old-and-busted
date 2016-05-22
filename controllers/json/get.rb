get '/api' do
  headers 'Content-Type' => 'application/json'
  { info: 'Negoto REST API' }.to_json
end

get '/api/boards' do
  headers 'Content-Type' => 'application/json'
  Board.all.to_json
end

get '/api/:board_id/' do |board_id|
  headers 'Content-Type' => 'application/json'
  begin
    Board[board_id].yarns.to_json
  rescue BoardNotFound => e
    pass
  end
end

get '/api/:board_id' do |board_id|
  redirect "/api/#{board_id}/"
end

get '/api/:board_id/thread/:yarn_id' do |board_id, yarn_id|
  headers 'Content-Type' => 'application/json'
  begin
    Yarn[board_id, yarn_id].all.to_json
  rescue BoardNotFound, YarnNotFound => e
    pass
  end
end
