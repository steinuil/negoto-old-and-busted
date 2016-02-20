require "sequel"

class REM
  def self.connect options
    @db = Sequel.connect options
    @@boards = @db[:boards]
    @@yarns = @db[:yarns]
    @@posts = @db[:posts]
    @@cooldowns = @db[:cooldowns]
    @@files = @db[:files]

    @@count = @@boards.to_hash(:id, :count)
  end
end

%w[attachment board yarn post cooldown].each do |l|
  require_relative "somnograph/#{l}"
end

["image"].each do |l|
  require_relative "attachment/#{l}"
end
