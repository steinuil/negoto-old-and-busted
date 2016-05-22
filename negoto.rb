require 'sinatra'

DATA_DIR = ''
PUBLIC_DIR = DATA_DIR + 'public'

require_relative 'models/models'
require_relative 'controllers/controllers'

REM.connect adapter: 'sqlite', database: 'db.db'
