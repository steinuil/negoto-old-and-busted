get "/api" do
  "Negoto REST API blah blah blah"
end

get "/api/boards" do
  headers "Content-Type" => "application/json"
  Board.list.to_json
end

get "/api/:board_id/" do |board_id|
  redirect "/api/#{board_id}"
end

get "/api/:board_id" do |board_id|
  headers "Content-Type" => "application/json"
  yarns = Board[board_id].to_hash
  yarns.map! do |yarn|
    yarn[:file] = eval yarn[:file]
    yarn
  end
  yarns.to_json
end

get "/api/:board_id/thread/:thread_id" do |board_id, thread_id|
  headers "Content-Type" => "application/json"
  yarn = Yarn[board_id, thread_id].posts
  yarn = yarn.unshift(Yarn[board_id, thread_id].to_hash)
  yarn.map! do |post|
    post[:file] = eval post[:file] if post[:file] 
    post
  end
  yarn.to_json
end
