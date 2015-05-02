require 'mongo'

database = Mongo::Client.new(['127.0.0.1:27017'], database: 'shuko')
board = database[:snw]
stats = database[:statistics]

board.find.to_a.each do |thread|
  @op = thread["op"]
  puts @op["name"]
  puts @op["body"]
  thread["posts"].each do |post|
    puts post["name"]
    puts post["body"]
  end
end
