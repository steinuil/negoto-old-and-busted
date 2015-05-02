require 'mongo'
require 'erb'

database = Mongo::Client.new(['127.0.0.1:27017'], :database => 'shuko')
stats = database[:statistics]
board = database[:snw]

board.drop
stats.drop
stats.insert_one({ board: "snw",
                   name: "Time-Telling Fortress",
                   post_no: 0 })

@info = stats.find({ board: "snw" }).to_a[0].to_h
@thread = []
render = ERB.new(File.read('template/index.erb'))
File.write('public/index.html', render.result(binding))
