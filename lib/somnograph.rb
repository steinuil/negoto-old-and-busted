require "sequel"

class REM
  def self.connect options
    @db = Sequel.connect options # { adapter: "sqlite", database: name }
    @@boards = @db[:boards]
    @@yarns = @db[:yarns]
    @@posts = @db[:posts]

    @@count = @@boards.to_hash(:id, :count)
  end
end

["board", "yarn", "post"].each { |f| require_relative f }
