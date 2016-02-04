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

%w[board yarn post].each { |l| require_relative "somnograph/#{l}" }
