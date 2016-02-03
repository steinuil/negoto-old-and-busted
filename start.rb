require_relative "lib/somnograph"
require "sequel"
require "fileutils"

if ARGV[0] == "reset"
  File.delete "negoto.db"
  FileUtils.rm_r "public/thumb"
  FileUtils.rm_r "public/src"
end

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
  Integer :yarn

  String :name
  DateTime :time
  String :body, text: true
  FalseClass :spoiler
  String :file
end

REM.connect adapter: "sqlite", database: "negoto.db"

Board.create id: "snw", name: "Time-Telling Fortress"
Board.create id: "gemu", name: "Video Games"
Board.create id: "med", name: "Medecine"

Dir.mkdir "public" unless Dir.exist? "public"
Dir.mkdir "public/banners" unless Dir.exist? "public/banners"
Dir.mkdir "public/thumb"
Dir.mkdir "public/src"
