require "json"

%w[get post].each { |l| require_relative "api/#{l}" }
