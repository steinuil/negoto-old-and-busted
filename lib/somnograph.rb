require "sequel"

class REM
  def self.connect options
    @db = Sequel.connect options
    @@boards = @db[:boards]
    @@yarns = @db[:yarns]
    @@posts = @db[:posts]
    @@cooldowns = @db[:cooldowns]

    @@count = @@boards.to_hash(:id, :count)
  end
end

%w[board yarn post cooldown].each do |l|
  require_relative "somnograph/#{l}"
end
