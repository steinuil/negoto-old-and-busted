require "json"

%w[get].each { |l| require_relative "api/#{l}" }
