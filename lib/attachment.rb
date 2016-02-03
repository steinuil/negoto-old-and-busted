require "mini_magick"

MiniMagick.configure do |config|
  config.cli = :graphicsmagick
end

class Attachment
  def self.add attachment, op
    attachment = new attachment
    attachment.thumb(op == :op)
    return attachment.info
  end

  def initialize attachment
    @attachment = attachment
    @ext = get_ext attachment[:type]
    @name = Time.now.strftime "%s%3N"
    @thumbname = @name + "s"

    @path = "public/src/#{@name}.#{@ext}"
    File.open(@path, "wb") do |f|
      f.write @attachment[:tempfile].read
    end

    @file = MiniMagick::Image.open @path
  end

  def get_ext mimetype
    case mimetype
    when "image/jpeg"
      "jpg"
    when "image/png"
      "png"
    when "image/gif"
      "gif"
    when "video/webm"
      "webm"
    end
  end

  def thumb op
    if ["jpg", "png", "gif"].include? @ext
      @size = op ? "250x250" : "150x150"
      @thumbpath = "public/thumb/#{@thumbname}.jpg"

      @thumb = MiniMagick::Image.open(@path)
      @thumb.background op ? "#EEF2FF" : "#D6DAF0"
      @thumb.extent "0x0"
      @thumb.resize @size
      @thumb.format "jpg"
      @thumb.write @thumbpath
    end
  end

  def info
    {
      src: "#{@name}.#{@ext}",
      thumb: @thumbname + ".jpg",
      filename: @attachment[:filename],
      resolution: "#{@file.width}&times;#{@file.height}",
      size: @file.size
    }
  end
end
