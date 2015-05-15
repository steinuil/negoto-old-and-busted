require 'mongo'
require 'erb'
require 'fileutils'

database = Mongo::Client.new(['127.0.0.1:27017'], :database => 'shuko')
stats = database[:statistics]
board = database[:snw]

board.drop
stats.drop

FileUtils.rm_r(Dir.glob("public/src/*"))
FileUtils.rm_r(Dir.glob("cache/*"))

stats.insert_one({ board: "snw",
                   name: "Time-Telling Fortress",
                   post_no: 0 })

@info = stats.find({ board: "snw" }).to_a.first.to_h
@threads = []
render = ERB.new(File.read("views/top.erb")).result(binding)
File.write("cache/top", render)
