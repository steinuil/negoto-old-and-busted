class Board < REM
  # Access boards this way
  def self.[] id
    raise BoardNotFound if @@boards.where(id: id).all.empty?
    new(id)
  end

  # Only use when creating a new board
  def initialize id
    @id = id
    @board = @@boards.where(id: id)
  end

  def create name
    @@boards.insert(id: @id, name: name, count: 0)
  end

  def destroy
    Attachment.delete(board: @id)
    @board.delete
    @@yarns.where(board: @id).delete
    @@posts.where(board: @id).delete
  end

  # Attribute accessors

  attr_reader :id

  def name
    @board.map(:name).first
  end

  def name= new_name
    @board.update(name: new_name)
  end

  def count
    @board.map(:count).first
  end

  def count_incr
    @@db.transaction do
      @count = @board.map(:count).first + 1
      @board.update count: @count
    end
    @count
  end

  # IDs and content

  def self.all # -> Array of Hashes of info
    @@boards.select(:id, :name, :count).all
  end

  def self.ids # -> Array of ids
    @@boards.map(:id)
  end

  def yarns # -> Array of Hashes of OPs
    @@yarns
      .where(board: @id).order(:updated).select(
        :id, :locked, :subject, :name, :time, :body, :spoiler,
        :file, :updated, :count).all
      .map do |post|
        post[:file] = Attachment[post[:file]].info
        post
      end
  end

  def yarn_ids
    @@yarns.where(board: @id).map(:id)
  end

  def post_ids
    @@posts.where(board: @id).map(:id)
  end
end
