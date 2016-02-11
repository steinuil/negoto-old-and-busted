require "io/console"
require_relative "lib/somnograph"
require_relative "lib/eval_line"

REM.connect adapter: "sqlite", database: "negoto.db"

def quit() puts "See you!"; exit end

cols = IO.console.winsize[1]
$version = 0.01
puts " Good Day, Brother. ".center(cols, "#")
puts " Hello By The Negoto v#{$version} Admin Panel. ".center(cols, "#")

loop do
  print "> "
  line = gets
  quit if line.nil? or line.chomp! == "exit"

  line = line.split " "

  res = eval_line line
  puts res if res
end
