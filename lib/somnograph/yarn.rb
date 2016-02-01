class Yarn < REM
  def self.list board=nil
    board ? @@yarns.where(board: board) : @@yarns
  end

  def initialize board, id
    @id = id
    @board = board
    @this = @@yarns.where(board: board, id: id)
  end

  def self.create post
    @id = @@count[post[:board]] += 1
    @time = Time.now
    post.merge!({ id: @id, time: @time, updated: @time, locked: false })

    @@yarns.insert post
    Board[post[:board]].incr
    #FIXME cache yarn
    return new(post[:board], @id)
  end

  def self.[] board, id
    @@yarns.where(board: board, id: id) ? new(board, id) : nil
  end

  attr_reader :id, :board

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

  def posts
    @@posts.where(board: @board, yarn: @id)
  end

  def list_posts
    posts().all.map :id
  end

  def include? post_id
    list_posts().include? post_id
  end

  def delete
    @this.delete
    @@posts.where(board: @board, yarn: @id).delete
    #FIXME delete some files
  end
end
