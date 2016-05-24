require 'tilt/haml'
require 'tilt/sass'
require 'json'

configure do
  set :bind, '0.0.0.0'
  set :sass, { style: :expanded }
  set :public_folder, PUBLIC_DIR
  set :views, sass: 'views/sass', haml: 'views/haml', js: 'views/js'
end

helpers do
  def find_template(views, name, engine, &block)
    _, folder = views.detect { |k,v| engine == Tilt[k] }
    super(folder, name, engine, &block)
  end
end

%w[helpers get post error].each do |f|
  require_relative "html/#{f}"
end

%w[get error].each do |f|
  require_relative "json/#{f}"
end
