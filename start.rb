boards = [
  { id: 'snw', name: 'Time-Telling Fortress' }
]

db = Sequel.connect adapter: 'sqlite', database: DATABASE

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
  String :ip
  foreign_key :file, :files
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
  String :ip
  foreign_key :file, :files
end

db.create_table :cooldowns do
  String :ip
  DateTime :time
end

db.create_table :files do
  primary_key :id
  String :board
  Integer :yarn

  String :name
  String :src
  String :thumb
  Integer :thumb_w
  Integer :thumb_h
  Integer :size
end

REM.connect adapter: 'sqlite', database: DATABASE

boards.each do |board|
  Board.new(board[:id]).create board[:name]
end

Dir.mkdir(PUBLIC) rescue nil
Dir.chdir PUBLIC do
  %w[crests thumb src].each do |dir|
    Dir.mkdir(dir) rescue nil
  end
end
