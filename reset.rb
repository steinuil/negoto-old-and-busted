require 'mongo'
require 'erb'
require 'fileutils'

database = Mongo::Client.new(['127.0.0.1:27017'], :database => 'negoto')
info = database[:info]

board_id = "snw"
#Dir.mkdir("cache/#{board_id}")

info.insert_one({ board: board_id, name: "Time-Telling Fortress", post_no: 0 })
info.insert_one({ t: "list", boards: [board_id]})
@info = info.find(board: board_id).to_a.first.to_h
@threads = []
render = ERB.new(File.read('views/top.erb')).result(binding)
File.write("cache/#{board_id}/top", render)


#if ARGV[0] == "-start" or ARGV[0] == "-reset"
#  if ARGV[0] == "-reset"
#    board.drop
#    stats.drop
#    FileUtils.rm_r(Dir.glob("public/src/*"))
#    FileUtils.rm_r(Dir.glob("cache/*"))
#  elsif ARGV[0] == "-start"
#    Dir.mkdir("cache")
#    Dir.mkdir("public/banners")
#    Dir.mkdir("public/src")
#  end
#
#  stats.insert_one({ board: "snw",
#                     name: "Time-Telling Fortress",
#                     post_no: 0 })
#
#  @info = stats.find(board: "snw").to_a.first.to_h
#  @threads = []
#  render = ERB.new(File.read("views/top.erb")).result(binding)
#  File.write("cache/top", render)
#else
#  puts "Usage: ./reset.rb (-start|-reset)"
#end

