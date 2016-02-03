post "/api/:board_id" do |board_id|
  @err = if not Board.list.include? board_id
    "no_board"
  elsif params[:subject].empty?
    "no_subject"
  elsif params[:file].nil?
    "no_image"
  end

  redirect "/error/#{@err}" if @err

  params[:file] = Attachment.add(params[:file], :op).to_s
  params[:name] = "Anonymous" if params[:name].empty?
  params[:spoiler] = params[:spoiler] == "on" ? true : false

  @post = {
    board: board_id,
    subject: params[:subject].escape,
    name: params[:name].escape,
    body: params[:body].format,
    spoiler: params[:spoiler],
    file: params[:file] }

  @thread = Yarn.create @post

  "Post successful"
end

post "/api/:board_id/thread/:thread_id" do |board_id, thread_id|
  @err = if not Board.list.include? board_id
    "no_board"
  elsif not Board[board_id].list.include? thread_id.to_i
    "no_thread"
  elsif params[:file].nil? and params[:body].empty?
    "no_comment"
   end

  redirect "/error/#{@err}" if @err

  params[:file] = if params[:file]
    Attachment.add(params[:file], :post).to_s
  else "" end
  params[:name] = "Anonymous" if params[:name].empty?
  params[:spoiler] = params[:spoiler] ==  "on" ? true : false
  params[:sage] = params[:sage] == "on" ? true : false

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

  "Post successful"
end
