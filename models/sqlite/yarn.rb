class Yarn < REM
  # Access yarns this way
  def self.[] board, id
    raise BoardNotFound unless @@boards.where(board: board)
    raise YarnNotFound unless @@yarns.where(board: board, id: id)
    new(board, id)
  end

  # Only use when creating a new yarn
  def initialize board, id = nil
    @id = id
    @board = board
    @yarn = @@yarns.where(board: board, id: id)
  end

  def create(name: 'Anonymous', body: '', spoiler: false,
             subject: nil, ip: nil, file: nil) # Required parameters
    time = Time.now
    file_id = time.strftime('%s%3N').to_i

    Attachment.new(file_id).create(
      file, @board, @id, spoiler, true)

    @@db.transaction do
      @id = Board[@board].count_incr
      @@yarns.insert(
        board: @board, id: @id,
        updated: time, locked: false, count: 0,
        subject: subject, name: name, body: body,
        file: file_id, time: time, spoiler: spoiler,
        ip: Cooldown.checksum(ip))
    end

    @yarn = @@yarns.where(board: @board, id: @id)
  end

  def destroy
    @yarn.delete
    @@posts.where(board: @board, yarn: @id).delete
    Attachment.delete(board: @board, yarn: @id)
  end

  # Attribute accessors

  attr_reader :id, :board

  def subject
    @yarn.map(:subject).first
  end

  def subject= new_subject
    @yarn.update(subject: new_subject)
  end

  def ip
    @yarn.map(:ip).first
  end

  def locked?
    @yarn.map(:locked).first
  end

  def locked= bool
    @yarn.update(locked: bool)
  end

  def bump time = Time.now
    @yarn.update(updated: time)
  end

  def count
    @yarn.map(:count).first
  end

  def count_incr
    @@db.transaction do
      @count = @yarn.map(:count).first + 1
      @yarn.update count: @count
    end
    @count
  end

  # IDs and content

  def op # -> Hash of info
    y = @yarn.select(:id, :locked, :subject, :name, :time,
                     :spoiler, :file).first
    y[:file] = Attachment[y[:file]].info
    y
  end

  def posts # -> Array of Hashes of posts
    @@posts
      .where(board: @board, yarn: @id)
      .select(:id, :name, :time, :body, :spoiler, :file).all
      .map do |post|
        post[:file] = Attachment[post[:file]].info if post[:file]
        post
      end
  end

  def all
    posts.unshift op
  end

  def post_ids
    @@posts.where(board: @board, yarn: @id).map(:id)
  end
end
