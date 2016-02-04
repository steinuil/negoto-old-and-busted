require "rack/utils"

class String
  def format
    text = self.split(/\R/).join "\n"
    text = Rack::Utils.escape_html(text).split /\R?^```\R*/
    text.map!.with_index do |string, counter|
      if counter.even?
        string.gsub! /\\\\(.+?)(\\\\|\z)/,
          '<span class="spoiler">\1</span>'
        @lines = string.split(/\R/).map do |line|
          line.gsub /^(&gt;.+)$/,
            '<span class="quote">\1</span>'
        end
        @lines.join "<br>"
      else
        string = string.split(/\R/).join "<br>"
        "<pre>" + string + "</pre>"
      end
    end
    text = text.delete_if do |section|
      section.empty? or section == "<pre></pre>"
    end
    text.join "<br>" #huehuehuehuehuehuehuehue
  end

  def escape
    Rack::Utils.escape_html(self)
  end
end
