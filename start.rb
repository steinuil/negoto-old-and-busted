require_relative "lib/somnograph"
require "sequel"
require "fileutils"
require "yaml"

config = YAML.load(File.read("config.yml"))

if ARGV[0] == "reset"
  File.delete config[:database]
  FileUtils.rm_r "public/thumb"
  FileUtils.rm_r "public/src"
end

db = Sequel.connect adapter: config[:adapter],
                    database: config[:database]

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
  Integer :count
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

db.create_table :cooldowns do
  primary_key :cid
  String :ip
  DateTime :time
end

REM.connect  adapter: config[:adapter],
             database: config[:database]

config[:boards].each do |board|
  Board.create id: board[:id], name: board[:name]
end

Dir.mkdir "public" unless Dir.exist? "public"
Dir.mkdir "public/banners" unless Dir.exist? "public/banners"
Dir.mkdir "public/thumb"
Dir.mkdir "public/src"
