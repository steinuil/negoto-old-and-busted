class Attachment < REM
  def self.delete range
    @files = unless range[:yarn]
      @@files.where(board: range[:board])
    else
      @@files.where(board: range[:board], yarn: range[:yarn])
    end

    @files.map(:fname).each do |file|
      File.delete("public/src/#{file}")
      File.delete("public/thumb/#{file.split(".")[0]}.jpg")
    end

    @files.delete
  end

  def self.create opts
    @ext = self.get_ext opts[:file][:type]
    @name = Time.now.strftime("%s%3N").to_s
    if %[jpg png gif].include? @ext
      @info = self.write_image(opts[:file], @ext, opts[:spoiler],
                               opts[:op], @name)
    end

    @@files.insert(board: opts[:board], yarn: opts[:yarn],
                   post: opts[:post], fname: "#{@name}.#{@ext}")
    return @info
  end

  def initialize board, post
    @board = board
    @this = @@files.where(board: board, post: post)
  end

  def self.[] board, post
    if @@files.where(board: board, post: post)
      new(board, post)
    else nil end
  end

  def delete
    @this.delete
  end

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
end
