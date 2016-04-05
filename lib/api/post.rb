post "/api/:board_id" do |board_id|
  headers "Content-Type" => "application/json"
  params = JSON.parse request.body.read
  params.keys.each { |key| params[key.to_sym] = params.delete(key) }

  @err = if Cooldown.include? request.ip
    "cooldown"
  elsif not Board.ids.include? board_id
    "no_board"
  elsif params[:subject].empty?
    "no_subject"
  elsif params[:file].nil?
    "no_image"
  elsif params[:subject].length > 140
    "subject_too_long"
  elsif params[:name].length > 50
    "name_too_long"
  elsif params[:body].length > 2000
    "post_too_long"
  end

  if @err
    status 400
    return { status: 400, err: @err }.to_json
  end

  # Fix parameters
  if not params[:name] or params[:name].empty?
    params[:name] = "Anonymous"
  end
  params[:body] ||= ""
  params[:spoiler] = params[:spoiler] ? params[:spoiler] == "on" : false

  post = {
    board: board_id,
    subject: params[:subject].escape,
    name: params[:name].escape,
    body: params[:body].format,
    spoiler: params[:spoiler],
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
  headers "Content-Type" => "application/json"
  params = JSON.parse request.body.read

  params.keys.each { |key| params[key.to_sym] = params.delete(key) }

  @err = if Cooldown.include? request.ip
    "cooldown"
  elsif not Board.ids.include? board_id
    "no_board"
  elsif not Board[board_id].yarn_ids.include? thread_id.to_i
    "no_thread"
  elsif Yarn[board_id, thread_id].locked?
    "thread_locked"
  elsif params[:file].nil? and params[:body].empty?
    "no_comment"
  elsif params[:name] and params[:name].length > 50
    "name_too_long"
  elsif params[:body] and params[:body].length > 2000
    "post_too_long"
  end

  if @err
    status 400
    return { status: 400, err: @err }.to_json
  end

  if not params[:name] or params[:name].empty?
    params[:name] = "Anonymous"
  end
  params[:body] ||= ""
  params[:spoiler] = params[:spoiler] ? params[:spoiler] == "on" : false
  params[:sage] = params[:sage] ? params[:sage] == "on" : false
  params[:file] = params[:file] ? params[:file] : ""

  post = {
    board: board_id,
    yarn: thread_id,
    name: params[:name].escape,
    body: params[:body].format,
    spoiler: params[:spoiler],
    sage: params[:sage],
    ip: request.ip,
    file: params[:file] }

  Post.create post
  Cooldown.add request.ip

  status 201
  a = { message: "OK" }
  a.to_json
end
