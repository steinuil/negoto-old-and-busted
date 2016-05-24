require 'sinatra'

DATA_DIR = '.'.freeze
PUBLIC = "#{DATA_DIR}/public".freeze
DATABASE = "#{DATA_DIR}/db.db".freeze

require_relative 'models/models'
require_relative 'controllers/controllers'

load 'start.rb' unless File.exists? DATABASE

REM.connect adapter: 'sqlite', database: DATABASE
