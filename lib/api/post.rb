def invalid? p, ip, board, yarn = nil
  if Cooldown.include? ip
    "cooldown"
  elsif yarn and Yarn[board, yarn].locked?
    "thread locked"
  elsif not yarn and p[:file].nil?
    "no file"
  elsif yarn and p[:file].nil? and p[:body].empty?
    "no comment"
  elsif not yarn and p[:subject].length > 140
    "subject too long"
  elsif p[:name].length > 50
    "name too long"
  elsif p[:body].length > 2000
    "post too long"
  else
    nil
  end
end

post "/api/:board_id" do |board_id|
  pass unless Board.ids.include? board_id

  headers "Content-Type" => "application/json"
  params = JSON.parse request.body.read
  params.keys.each { |key| params[key.to_sym] = params.delete(key) }

  # name, subject, body, spoiler, file

  params[:name]    ||= "Anonymous"
  params[:subject] ||= ""
  params[:body]    ||= ""
  params[:spoiler] ||= "off"

  if err = invalid?(params, request.ip, board_id)
    halt 400, { status: 400, err: err }.to_json
  end

  params[:name] = "Anonymous" if params[:name].empty?

  post = {
    board: board_id,
    subject: params[:subject].escape,
    name: params[:name].escape,
    body: params[:body].format,
    spoiler: params[:spoiler] == "on",
    ip: request.ip,
    file: params[:file]
  }

  Yarn.create post
  Cooldown.add request.ip

  status 201
  a = { message: "OK" }
  a.to_json
end

post "/api/:board_id/thread/:thread_id" do |board_id, thread_id|
  pass unless Board.ids.include? board_id
  pass unless Board[board_id].yarn_ids.include? thread_id.to_i

  #p Board[board_id].yarn_ids.include? thread_id.to_i
  #halt 404

  headers "Content-Type" => "application/json"
  params = JSON.parse request.body.read

  params.keys.each { |key| params[key.to_sym] = params.delete(key) }

  # name, body, spoiler, sage, file
  
  params[:name]    ||= "Anonymous"
  params[:body]    ||= ""
  params[:spoiler] ||= "off"
  params[:sage]    ||= "off"

  if err = invalid?(params, request.ip, board_id, thread_id)
    halt 400, { status: 400, err: err }.to_json
  end

  params[:name] = "Anonymous" if params[:name].empty?
  params[:file] = params[:file] ? params[:file] : ""

  post = {
    board: board_id,
    yarn: thread_id,
    name: params[:name].escape,
    body: params[:body].format,
    spoiler: params[:spoiler] == "on",
    sage: params[:sage] == "on",
    ip: request.ip,
    file: params[:file] }

  Post.create post
  Cooldown.add request.ip

  status 201
  a = { message: "OK" }
  a.to_json
end
