require "mini_magick"

%w[image].each { |l| require_relative "attachment/#{l}" }

MiniMagick.configure do |config|
  config.cli = :graphicsmagick
end

class Attachment
  def self.get_ext mimetype
    case mimetype
    when "image/jpeg"
      "jpg"
    when "image/png"
      "png"
    when "image/gif"
      "gif"
    end
  end

  def self.add attachment, spoiler, op
    @ext = self.get_ext attachment[:type]
    if %[jpg png gif].include? @ext
      self.write_image attachment, @ext, spoiler, op == :op
    end
  end
end
