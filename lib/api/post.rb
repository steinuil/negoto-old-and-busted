post "/api/:board_id" do |board_id|
  @err = if not Board.list.include? board_id
    "no_board"
  elsif params[:subject].empty?
    "no_subject"
  elsif params[:file].nil?
    "no_image"
  elsif params[:subject].length > 30
    "subject_too_long"
  elsif params[:name].length > 30
    "name_too_long"
  elsif params[:body].length > 2000
    "post_too_long"
  end

  redirect "/error/#{@err}" if @err

  params[:spoiler] = params[:spoiler] == "on"
  params[:file] = Attachment.add(params[:file], params[:spoiler], :op).to_s
  params[:name] = "Anonymous" if params[:name].empty?

  @post = {
    board: board_id,
    subject: params[:subject].escape,
    name: params[:name].escape,
    body: params[:body].format,
    spoiler: params[:spoiler],
    file: params[:file] }

  @thread = Yarn.create @post

  #Cooldown.add request.ip

  "Post successful"
end

post "/api/:board_id/thread/:thread_id" do |board_id, thread_id|
  @err = if not Board.list.include? board_id
    "no_board"
  elsif not Board[board_id].list.include? thread_id.to_i
    "no_thread"
  elsif params[:file].nil? and params[:body].empty?
    "no_comment"
  elsif params[:name].length > 50
    "name_too_long"
  elsif params[:body].length > 2000
    "post_too_long"
  end

  redirect "/error/#{@err}" if @err

  params[:spoiler] = params[:spoiler] ==  "on"
  params[:file] = if params[:file]
    Attachment.add(params[:file], params[:spoiler], :post).to_s
  else "" end
  params[:name] = "Anonymous" if params[:name].empty?
  params[:sage] = params[:sage] == "on"

  @post = {
    board: board_id,
    yarn: thread_id,
    name: params[:name].escape,
    body: params[:body].format,
    spoiler: params[:spoiler],
    sage: params[:sage],
    file: params[:file]
  }

  @post = Post.create @post

  #Cooldown.add request.ip

  "Post successful"
end
