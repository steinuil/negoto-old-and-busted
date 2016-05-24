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
    Dir.chdir(PUBLIC_DIR) { Dir.glob('crests/*').sample }
  end
end

require 'rack/utils'

class String
  def format_post
    Rack::Utils.escape_html(self).split(/\R?^```\R*/).map.with_index do |string, c|
      if c.even?
        string.gsub(/\\\\(.+?)(\\\\|\z)/, '<span class="spoiler">\1</span>').split(/\R/).map do |line|
          line.gsub(/(\A| )&gt;&gt;([0-9]+)(\Z| )/,
            '\1<a onmouseover="preview.show(this);" onmouseout="preview.destroy();" class="backquote" href="#p\2">&gt;&gt;\2</a>\3')
            .gsub(/^(&gt;.+)$/, '<span class="quote">\1</span>')
        end.join '<br>'
      else
        '<pre>%s</pre>' % string.split(/\R/).join('<br>')
      end
    end.reject { |s| s.empty? or s == '<pre></pre>' }.join '<br>'
  end

  def escape_html
    Rack::Utils.escape_html(self)
  end
end
