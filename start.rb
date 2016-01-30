require_relative "lib/somnograph"
require "sequel"

db = Sequel.sqlite "negoto.db"

db.create_table :boards do
  primary_key :bid
  String :id
  String :name
  Integer :count
end

db.create_table :yarns do
  primary_key :yid
  Integer :id
  String :board
  FalseClass :locked
  DateTime :updated
  String :subject

  String :name
  DateTime :time
  String :body, text: true
  FalseClass :spoiler
  String :file
end

db.create_table :posts do
  primary_key :pid
  Integer :id
  String :board
  String :name
  DateTime :time
  String :body, text: true
  FalseClass :spoiler
  String :file
end

REM.connect adapter: "sqlite", database: "negoto.db"

Board.create id: "snw", name: "Time-Telling Fortress"
Board.create id: "gemu", name: "Vidya"
Board.create id: "loli", name: "Flat-Chested Maidens"
