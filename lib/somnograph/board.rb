class Board < REM
  def self.ids
    @@boards.map :id
  end

  def self.list
    @@boards.select(:id, :name).all
  end

  def initialize id
    @id = id
    @this = @@boards.where id: id
  end

  def self.[] id
    @@boards.where(id: id) ? new(id) : nil
  end

  def self.create options
    @@boards.insert(options.merge({ count: 0 }))
    return new(options[:id])
  end

  def name
    @@boards[id: @id][:name]
  end

  def name= new_name
    @this.update name: new_name
  end

  def count
    @this.map(:count).first
    #@@boards[id: @id][:count]
  end

  def incr
    @@db.transaction do
      @count = @this.map(:count).first + 1
      @this.update count: @count
    end
    return @count
  end

  def decr
    @@db.transaction do
      @count = @this.map(:count).first - 1
      @this.update count: @count
    end
    return @count
    #@this.update count: @@boards[id: @id][:count] - 1
  end

  def yarns
    @@yarns.where(board: @id).order(:updated).select(
      :id, :locked, :subject, :name, :time, :body, :spoiler,
      :file, :updated, :count).all
  end

  def yarn_ids
    @@yarns.where(board: @id).map :id
  end

  def post_ids
    @@posts.where(board: @id).map(:id)
  end

  def delete
    @@yarns.where(board: @id).delete
    @@posts.where(board: @id).delete
    Attachment.delete(board: @id)
  end
end
