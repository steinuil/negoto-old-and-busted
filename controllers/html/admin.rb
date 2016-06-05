get '/admin' do
  #response.set_cookie 'ayy', { value: [ 'lmao', 'nogf' ], expires: Time.now + 60 }
  #request.cookies
  haml :login, layout: :alt, locals: {
    title: 'Login',
    boards: Board.all
  }
end

#post '/admin' do
#  params[:email]
#end
