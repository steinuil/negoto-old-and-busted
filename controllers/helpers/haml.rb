helpers do
  def elapsed time
    elapsed = (Time.now - time).to_i
    name = if 60 > elapsed
      'second'
    elsif 60 > elapsed /= 60
      'minute'
    elsif 60 > elapsed /= 60
      'hour'
    elsif 24 > elapsed /= 24
      'day'
    elsif 7 > elapsed / 7
      elapsed /= 7 ; 'week'
    elsif 30 > elapsed / 30
      elapsed /= 30 ; 'month'
    else
      elapsed /= 365 ; 'year'
    end

    name += 's' if elapsed > 1
    "#{elapsed} #{name} ago"
  end

  def greeting
    case Time.now.hour
    when 6..11
      'morning'
    when 12..17
      'afternoon'
    when 18..21
      'evening'
    else
      'night'
    end
  end

  def crest
    Dir.chdir(PUBLIC) { Dir.glob('crests/*').sample }
  end
end
