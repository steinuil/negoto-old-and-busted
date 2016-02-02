class Board < REM
  def self.list
    @@boards.map :id
  end

  def self.names
    @@boards.select :id, :name
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
    #@@count[@id] nah
    @@boards[id: @id][:count]
  end

  def incr
    @this.update count: @@boards[id: @id][:count] + 1
  end

  def decr
    @this.update count: @@boards[id: @id][:count] - 1
  end

  def yarns
    #@@yarns.where(board: @id)
    @@yarns.where(board: @id).order(:time).select(
      :id, :locked, :subject, :name, :time, :body, :spoiler, :file)
  end

  def delete
    @this.delete
    @@yarns.where(board: @id).delete
    @@posts.where(board: @id).delete
    #FIXME delete some files
  end
end
