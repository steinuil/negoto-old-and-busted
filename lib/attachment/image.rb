class Attachment
  def self.write_image image, ext, op
    @image = image
    @ext = ext
    @name = Time.now.strftime("%s%3N").to_s
    @tname = @name + ".jpg"
    @name += ".#{ext}"

    # Save file
    @path = "public/src/#{@name}"
    File.open(@path, "wb") do |i|
      i.write @image[:tempfile].read
    end

    @file = MiniMagick::Image.open @path
    @info = {
      src: @name,
      thumb: @tname,
      filename: @image[:filename],
      resolution: "#{@file.width}&times;#{@file.height}",
      size: @file.size }

    # Save thumbnail
    #FIXME the colors below should be regulated
    #      by the default sass style
    @file.background op ? "#EEF2FF" : "#D6DAF0"
    @file.extent "0x0"
    #this could be regulated by config file
    @file.resize op ? "250x250" : "150x150"
    @file.format "jpg"
    @file.write "public/thumb/#{@tname}"

    return @info
  end
end
