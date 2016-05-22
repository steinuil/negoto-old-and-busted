require 'mini_magick'

MiniMagick.configure do |config|
  config.cli = :imagemagick
end

class Attachment::Image
  def self.thumb_size sizes, op
    longest = op ? 250 : 150
    thicc = sizes[0] > sizes[1]
    shortest = (sizes.min.to_f / sizes.max * longest).to_i
    thicc ? [longest, shortest] : [shortest, longest]
  end

  def self.save img, id, ext, spoiler, op
    file_name = "#{id}.#{ext}"
    if spoiler
      spoiler_img = op ? 'spoiler_op.jpg' : 'spoiler.jpg'
    else
      thumb_name = "#{id}.jpg"
    end

    path = PUBLIC_DIR + "/src/#{file_name}"
    File.open(path, 'wb') { |i| i.write img.read }

    file = MiniMagick::Image.open path
    size = thumb_size [file[:width], file[:height]], op

    unless spoiler
      file.background(op ? '#EEF2FF' : '#D6DAF0')
      file.extent '0x0'
      file.resize(op ? '250x250' : '150x150')
      file.format 'jpg'
      file.write PUBLIC_DIR + "/thumb/#{thumb_name}"
    end

    return {
      src: file_name,
      thumb: spoiler ? spoiler_img : thumb_name,
      thumb_w: size[0],
      thumb_h: size[1],
      size: file.size
    }
  end
end
