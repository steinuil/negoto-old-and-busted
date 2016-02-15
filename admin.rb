require "io/console"
require_relative "lib/somnograph"
require_relative "lib/eval_line"

REM.connect adapter: "sqlite", database: "negoto.db"

def quit() puts "Goodbye."; exit end

cols = IO.console.winsize[1]
$version = 0.01
puts " Good Day, Brother. ".center(cols)
puts " Hello By The Negoto v#{$version} Admin Console. ".center(cols)
puts "Type 'help' for a list of commands"
puts

loop do
  print "> "
  line = gets
  quit if line.nil? or line.chomp! == "exit"

  line = line.split " "

  eval_line line
  puts
end
