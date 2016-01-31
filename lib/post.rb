class Post < REM
  def initialize board, id
    @id = id
    @board = board
    @this = @@posts.where(board: board, id: id)
  end

  def self.create post
    @id = @@count[post[:board]] += 1
    post.merge!({ id: @id, time: Time.now })

    if post[:page] == 0
      return Yarn.create(post)
    else
      @yarn = Yarn.new(board: post[:board], id: @id)
      return nil if @yarn.locked?

      @sage = post.delete :sage
      @@posts.insert post
      Board[post[:board]].incr
      @yarn.bump unless @sage
      #FIXME cache yarn
      return new(@id)
    end
  end

  def self.[](board, id)
    @post = @@posts.where(board: board, id: id)

    if @post.map(:op).first
      Yarn.new(board, id)
    elsif @post
      new(board, id)
    else nil end
  end

  attr_reader :id

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
    #FIXME delete file
  end
end

