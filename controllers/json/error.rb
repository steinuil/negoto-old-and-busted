get '/api/*' do
  headers 'Content-Type' => 'application/json'
  { status: 404, err: 'not found' }.to_json
end

post '/api/*' do
  headers 'Content-Type' => 'application/json'
  { status: 404, err: 'not found' }.to_json
end
