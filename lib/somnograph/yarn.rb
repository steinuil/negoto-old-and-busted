class Yarn < REM
  def initialize board, id
    @id = id
    @board = board
    @this = @@yarns.where(board: board, id: id)
  end

  def self.create post
    @time = Time.now

    post[:file] = Attachment.create(
      board: post[:board],
      yarn: @id,
      post: @id,
      file: post[:file],
      spoiler: false,
      ip: post[:ip],
      op: true).to_s

    @@db.transaction do
      id = Board[post[:board]].incr
      @@yarns.insert post.merge({ id: id, time: @time,
                                  updated: @time, locked:false,
                                  count: 0 })
    end

    #FIXME cache yarn
    return new(post[:board], @id)
  end

  def self.[] board, id
    @@yarns.where(board: board, id: id) ? new(board, id) : nil
  end

  attr_reader :id, :board

  def to_hash
    @this.select(:id, :locked, :subject, :name, :time, :body,
      :spoiler, :file).first
  end

  def subject
    @this.map(:subject).first
  end

  def subject= new_subject
    @this.update subject: new_subject
  end

  def locked?
    @this.map(:locked).first
  end

  def locked= bool
    @this.update locked: bool
  end

  def bump
    @this.update updated: Time.now
  end

  def incr
    @@db.transaction do
      @count = @this.map(:count).first
      @this.update count: @count + 1
    end
    return @count + 1
  end

  def posts
    @@posts.where(board: @board, yarn: @id).select(:id, :name, :time,
      :body, :spoiler, :file).all
  end

  def post_ids
    @@posts.where(board: @board, yarn: @id).map :id
  end

  def ip
    @this.map(:ip).first
  end

  def delete
    @this.delete
    @@posts.where(board: @board, yarn: @id).delete
    Attachment.delete(board: @board, yarn: @id)
  end
end
