post '/post/:board_id/' do |board_id|
  # Check for errors

  yarn = Yarn.new board_id
  yarn.create(
    subject: params[:subject],
    name: params[:name],
    body: params[:body],
    spoiler: params[:spoiler] == 'on',
    ip: request.ip,
    file: params[:file])

  Cooldown.add request.ip

  status 201
  redirect "/#{board_id}/thread/#{yarn.id}"
end

post '/post/:board_id/thread/:yarn_id' do |board_id, yarn_id|
  # Check for errors

  post = Post.new board_id, yarn_id
  post.create(
    name: params[:name],
    body: params[:body],
    spoiler: params[:spoiler] == 'on',
    sage: params[:sage] == 'on',
    ip: request.ip,
    file: params[:file])

  Cooldown.add request.ip
  
  status 201
  redirect "/#{board_id}/thread/#{yarn_id}#p#{post.id}"
end
