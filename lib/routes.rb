require "tilt/haml"
require "tilt/sass"

%w[get post error helpers].each { |l| require_relative "routes/#{l}" }
