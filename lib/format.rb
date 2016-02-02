class Time
  def self.elapsed time
    @elapsed = self.now - time

    @when = if @elapsed < 60
      [@elapsed.to_i, "seconds"]
    elsif @elapsed < 60 * 60
      [(@elapsed / 60).to_i, "minutes"]
    elsif @elapsed < 60 * 60 * 60
      [(@elapsed / 60 / 60).to_i, "hours"]
    elsif @elapsed < 60 * 60 * 60 * 24
      [(@elapsed / 60 / 60 / 24).to_i, "days"]
    elsif @elapsed < 60 * 60 * 60 * 24 * 7
      [(@elapsed / 60 / 60 / 24 / 7).to_i, "weeks"]
    elsif @elapsed < 60 * 60 * 60 * 24 * 30
      [(@elapsed / 60 / 60 / 24 / 30).to_i, "months"]
    else
      [(@elapsed / 60 / 60 / 24 / 365).to_i, "years"]
    end
    "#{@when[0]} #{@when[1]} ago"
  end
end
