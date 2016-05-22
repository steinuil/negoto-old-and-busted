class Post < REM
  # Access posts this way
  def self.[] board, id
    raise BoardNotFound if @@boards.where(board: board).all.empty?
    raise PostNotFound if @@posts.where(board: board, id: id).all.empty?
    yarn = @@posts.where(board: board, id: id).map(:yarn).first
    new(board, yarn, id)
  end

  # Only use when creating a new post
  def initialize board, yarn, id = nil
    @id = id
    @board = board
    @yarn = yarn
    @post = @@posts.where(board: board, id: id)
  end

  def create(ip: nil, file: nil,
             name: 'Anonymous', body: '', spoiler: false, sage: false)
    time = Time.now
    yarn = Yarn[@board, @yarn]

    if file
      file_id = time.strftime('%s%3N').to_i
      Attachment.new(file_id).create(
        file, @board, @yarn, spoiler)
    end

    @@db.transaction do
      @id = Board[@board].count_incr
      @@posts.insert(
        board: @board, yarn: @yarn, id: @id,
        name: name, body: body, file: file_id,
        time: time, spoiler: spoiler,
        ip: Cooldown.checksum(ip))
    end

    yarn.count_incr
    yarn.bump unless sage

    @post = @@posts.where(board: @board, id: @id)
  end

  def destroy
    Attachment[@post.map(:file).first].destroy
    @post.delete
  end

  # Attribute accessors

  attr_reader :id, :yarn, :board

  def ip
    @post.map(:ip).first
  end

  # IDs and content

  def post
    p = @post.select(:id, :name, :time, :body, :spoiler, :file).all
    p[:file] = Attachment[p[:file]].info if p[:file]
    p
  end
end
