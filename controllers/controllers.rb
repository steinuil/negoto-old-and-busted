require 'tilt/haml'
require 'tilt/sass'
require 'json'

configure do
  set :sass, { style: :expanded }
  set :public_folder, PUBLIC_DIR
end

%w[helpers get post].each do |f|
  require_relative "html/#{f}"
end

%w[get error].each do |f|
  require_relative "json/#{f}"
end
