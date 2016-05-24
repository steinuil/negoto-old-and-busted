class Attachment::Image
  def self.thumb_size *sizes, spoiler, op
    return (op ? [250, 250] : [150, 150]) if spoiler
    longest = op ? 250 : 150
    thicc = sizes[0] > sizes[1]
    shortest = (sizes.min.to_f / sizes.max * longest).to_i
    thicc ? [longest, shortest] : [shortest, longest]
  end

  def self.save img, id, ext, spoiler, op
    file_name = "#{id}.#{ext}"

    path = "#{PUBLIC}/src/#{file_name}"
    File.open(path, 'wb') { |i| i.write img.read }

    file = MiniMagick::Image.open path
    size = thumb_size file[:width], file[:height], spoiler, op

    unless spoiler
      thumb_name = "#{id}.jpg"
      file.background(op ? '#EEF2FF' : '#D6DAF0')
      file.flatten
      file.resize '%sx%s' % size
      file.format 'jpg'
      file.write "#{PUBLIC}/thumb/#{thumb_name}"
    end

    return {
      src: file_name,
      thumb: spoiler ? 'spoiler.jpg' : thumb_name,
      thumb_w: size[0],
      thumb_h: size[1],
      size: file.size
    }
  end
end
