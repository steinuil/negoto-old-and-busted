get "/api" do
  "Negoto REST API blah blah blah"
end

get "/api/boards" do
  Board.names.all.to_json
end

get "/api/:board_id" do |board_id|
  
end

get "/api/:board_id/thread/:thread_id" do |board_id, thread_id|

end
