require "htmlentities"

class String
  def format
    text = HTMLEntities.new.encode(self).split(/\R```\R*/)
    text.map!.with_index do |string, counter|
      if counter.even?
        string.gsub! /\\(.*?)(\\|\z)/,
          '<span class="spoiler">\1</span>'
        @lines = string.split /\R/
        @lines.map! do |line|
          line.gsub /^(&gt;.+)$/,
            '<span class="quote">\1</span>'
        end
        @lines.join "<br>"
      else
        string = string.split(/\R/).join "<br>"
        "<pre>" + string + "</pre>"
      end
    end
    text.join "<br>" #huehuehuehuehuehuehuehue
  end

  def escape
    HTMLEntities.new.encode(self)
  end
end
