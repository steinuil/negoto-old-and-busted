require "mini_magick"

MiniMagick.configure do |config|
  config.cli = $config[:magick].to_sym
end

class Attachment
  def self.write_image image, ext, spoiler, op, name
    @image = image
    @ext = ext
    @name = name
    @tname = @name + ".jpg"
    @name += ".#{ext}"
    @spoilimg = op ? "spoiler_op.jpg" : "spoiler.jpg"

    # Save file
    @path = PUBLIC_DIR + "/src/#{@name}"
    File.open(@path, "wb") do |i|
      i.write @image[:tempfile].read
    end

    @file = MiniMagick::Image.open @path
    @info = {
      src: @name,
      thumb: spoiler ? @spoilimg : @tname,
      filename: @image[:filename],
      resolution: "#{@file.width}&times;#{@file.height}",
      size: @file.size }

    # Save thumbnail
    #FIXME the colors below should be regulated
    #      by the default sass style
    unless spoiler
      @file.background op ? "#EEF2FF" : "#D6DAF0"
      @file.extent "0x0"
      #this could be regulated by config file
      @file.resize op ? "250x250" : "150x150"
      @file.format "jpg"
      @file.write PUBLIC_DIR + "/thumb/#{@tname}"
    end

    return @info
  end
end
