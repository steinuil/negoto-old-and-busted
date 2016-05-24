not_found do
  status 404
  headers 'Content-Type' => 'text/html'
  haml :error, layout: :alt, locals: {
    boards: Board.all,
    title: '404 Not Found',
    message: 'The page you reached is unavailable.'
  }
end
