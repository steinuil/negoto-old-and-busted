def post_invalid? p, ip, board_id, yarn_id = nil
  Board[board_id]

  if c = Cooldown.include?(ip)
    "You must wait #{c} seconds to post."
  elsif p[:name].length > 50
    'Your name can\'t be longer than 50 chars.'
  elsif p[:body].length > 2000
    'Your post can\'t be longer than 2000 chars.'
  elsif !yarn_id and !p[:file]
    'You must post a file to open a thread.'
  elsif !yarn_id and p[:subject].length > 140
    'Your subject can\'t be longer than 140 chars.'
  elsif yarn_id and Yarn[board_id, yarn_id].locked?
    'This thread is locked.'
  elsif yarn_id and !p[:file] and p[:body].empty?
    'Your post must contain either a file or a comment.'
  else
    false
  end
rescue BoardNotFound, YarnNotFound => e
  e.message
rescue NoMethodError => e
  puts e.message
  'You forgot a parameter in your request.'
end

post '/post/:board_id/' do |board_id|
  if e = post_invalid?(params, request.ip, board_id)
    status 400
    if params[:xhr] or request.xhr?
      msg = e
    else
      msg = haml(:error, layout: :alt, locals: {
        boards: Board.all,
        title: 'Error',
        message: e
      })
    end
    halt msg
  end

  yarn = Yarn.new board_id
  yarn.create(
    subject: params[:subject].escape_html,
    name: params[:name].escape_html,
    body: params[:body].format_post,
    spoiler: params[:spoiler] == 'on',
    ip: request.ip,
    file: params[:file])

  status 201
  if params[:xhr] or request.xhr?
    'Success'
  else
    redirect "/#{board_id}/thread/#{yarn.id}"
  end
end

post '/post/:board_id/thread/:yarn_id' do |board_id, yarn_id|
  if e = post_invalid?(params, request.ip, board_id, yarn_id)
    status 400
    if params[:xhr] or request.xhr?
      msg = e
    else
      msg = haml(:error, layout: :alt, locals: {
        boards: Board.all,
        title: 'Error',
        message: e
      })
    end
    halt msg
  end

  post = Post.new board_id, yarn_id
  post.create(
    name: params[:name].escape_html,
    body: params[:body].format_post,
    spoiler: params[:spoiler] == 'on',
    sage: params[:sage] == 'on',
    ip: request.ip,
    file: params[:file])
  
  if params[:xhr] or request.xhr?
    'Success'
  else
    redirect "/#{board_id}/thread/#{yarn_id}#p#{post.id}"
  end
end
