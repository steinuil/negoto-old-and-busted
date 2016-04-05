require "sinatra"
require "yaml"

$config = YAML.load(File.read("config.yml"))

DATA_DIR = ""
PUBLIC_DIR = DATA_DIR + "public"

%w[somnograph routes api format].each do |l|
  require_relative "lib/#{l}"
end

configure do
  set :bind, "0.0.0.0"
  set :server, :thin
  set :port, 6789
  set :logging, false
  set :sass, { style: :expanded }
  set :public_folder, PUBLIC_DIR
end

REM.connect adapter: $config[:adapter],
            database: DATA_DIR + $config[:database]
