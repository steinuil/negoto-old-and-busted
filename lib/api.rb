require "json"

%w[get post].each { |l| require_relative "api/#{l}" }

get "/api/*" do
  headers "Content-Type" => "application/json"
  #status 404
  { status: 404, err: "not found" }.to_json
end

post "/api/*" do
  headers "Content-Type" => "application/json"
  #status 404
  { status: 404, err: "not found" }.to_json
end
