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
