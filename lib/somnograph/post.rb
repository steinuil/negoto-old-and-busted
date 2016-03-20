class Post < REM
  def initialize board, id
    @id = id
    @board = board
    @this = @@posts.where(board: board, id: id)
  end

  def self.create post
    @id = @@count[post[:board]] += 1
    post.merge!({ id: @id, time: Time.now })

    unless post[:file].empty?
      post[:file] = Attachment.create(
        board: post[:board],
        yarn: post[:yarn],
        post: @id,
        file: post[:file],
        spoiler: post[:spoiler],
        ip: post[:ip],
        op: false).to_s
    end

    @yarn = Yarn[post[:board], post[:yarn]]
    @sage = post.delete :sage
    @@posts.insert post
    Board[post[:board]].incr
    @yarn.incr
    @yarn.bump unless @sage
    #FIXME cache yarn
    return new(post[:board], @id)
  end

  def self.[](board, id)
    if @@posts.where(board: board, id: id)
      new(board, id)
    else nil end
  end

  attr_reader :id

  def ip
    @this.map(:ip).first
  end

  def yarn
    @this.map(:yarn).first
  end

  def time
    @this.map(:time).first
  end

  def edit changes
    @this.update changes
  end

  def delete
    @this.delete
    @@files.where(board: @board, parent: @id).delete
    Attachment[board: @board, post: @id].delete
  end
end

