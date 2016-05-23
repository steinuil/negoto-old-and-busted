class Attachment < REM
  def self.[] id
    raise FileNotFound unless @@files.where(id: id)
    new(id)
  end

  def initialize id
    @id = id
    @file = @@files.where(id: id)
  end

  def create file, board, yarn, spoiler, op = false
    ext = get_ext file[:type]
    info = Attachment::Image
      .save(file[:tempfile], @id, ext, spoiler, op)
      .merge(id: @id, board: board, yarn: yarn, name: file[:filename])

    @@files.insert info
  end

  def destroy
    ext = @file.map(:ext).first
    File.delete(PUBLIC_DIR + "/src/#{@id}.#{ext}")
    File.delete(PUBLIC_DIR + "/thumb/#{@id}.jpg")
    @file.delete
  end

  # Attribute accessors

  attr_reader :id

  def info
    @file.select(
      :id, :name, :src, :thumb, :thumb_w, :thumb_h, :size).all.first
  end

  def board
    @file.map(:board).first
  end

  def yarn
    @file.map(:yarn).first
  end

  # Utilities

  def get_ext mimetype
    case mimetype
    when 'image/jpeg'
      'jpg'
    when 'image/png'
      'png'
    when 'image/gif'
      'gif'
    end
  end

  def self.delete board: id, yarn: nil
    files = if yarn
      @@files.where(board: board, yarn: yarn)
    else
      @@files.where(board: board)
    end

    files.map(:src).each do |file|
      File.delete(PUBLIC_DIR + "/src/#{file}")
      File.delete(PUBLIC_DIR + "/thumb/#{file.split('.')[0]}.jpg")
    end

    files.delete
  end
end
