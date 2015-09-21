require 'erb'
require 'htmlentities'
require 'rouge'
require 'mini_magick'

class Chan
  def initialize(client)
    @client = client
  end

  def get_collection(coll)
    return @client[coll]
  end

  def info
    return get_collection(:info)
  end

  def boards
    @list = @client.database.collection_names
    @list.delete("info")
    return @list
  end

  def include?(query)
    return boards().include?(query)
  end
end

class Board
  def initialize(chan, board_id)
    @info = chan.info
    @board = chan.get_collection(board_id)
    @board_id = board_id
  end

  def get_post_number
    return @info.find(board: @board_id).to_a.first.to_h["post_no"]
  end

  def get_id() return @board_id end
  def info() return @info end
  def board() return @board end

  def create(full_name)
    @info.insert_one({
      board: @board_id,
      name: full_name,
      post_no: 0 })
    @board.insert_one({
      thread: 0,
      op: {
        no: 0,
        name: "Anonymous",
        body: "First post for /#{@board_id}/ - #{full_name}.",
        posts: [],
        updated: Time.now } })
    @board.find({ thread: 0 }).delete_one
    Dir.mkdir("cache/#{@board_id}")
  end

  def delete
    @info.find(board: @board_id).delete_one
    @board.drop
    Dir.rmdir("cache/#{@board_id})")
  end

  def threads
    @threads = @board.find.sort(updated: -1).to_a
    return @threads == 0 ? [] : @threads
  end

  def cache
    @threads = threads()
    @render = ERB.new(File.read("views/top.erb")).result(binding)
    File.write("cache/#{@board_id}/top", @render)
  end

  def include?(thread_id)
    return @board.find(thread: thread_id).count != 0
  end
end

class Dis
  def initialize(board, thread_id)
    @info = board.info
    @board = board.board
    @board_id = board.get_id
    @thread_id = thread_id
  end

  def get_id() return @thread_id end
  def get_board() return @board_id end

  def info() return @info end
  def board() return @board end

  def get
    @board.find(thread: @thread_id).to_a.first
  end

  def cache
    @thread = get()
    @render = ERB.new(File.read("views/thread.erb")).result(binding)
    File.write("cache/#{@board_id}/#{@thread_id}", @render)
  end

  def create(post)
    @board.insert_one({
      thread: @thread_id,
      op: post,
      posts: [],
      updated: Time.now })
  end

  def update
    @info.find(board: @board_id).update_one("$inc" => { post_no: 1 })
  end

  def bump(now)
    @board.find(thread: @thread_id).update_one("$set" => { updated: now })
  end
end

class Post
  def initialize(thread, post_id)
    @info = thread.info
    @board = thread.board
    @thread = thread
    @thread_id = thread.get_id
    @post_id = post_id
  end

  def get_id() return @post end
  def get_thread() return @thread end

  def op?
    return @thread_id == @post_id
  end

  def create(content)
    if op?()
      @thread.create(content)
    else
      @board.find(thread: @thread_id).update_one("$push" => { posts: content })
    end
    @thread.update()
    @thread.cache()
  end
end

class Picture
  def initialize(image, now)
    @image = image
    @format = get_extension(@image[:type])
    @name = now.to_i.to_s
    @path = "public/src/#{@name + @format}"
    @thumbname = @name + "s"
    @thumbpath = "public/thumb/#{@thumbname + ".jpg"}"

    File.open(@path, 'wb') do |f|
      f.write(@image[:tempfile].read)
    end

    @image_file = MiniMagick::Image.open(@path)
  end

  def get_extension(mimetype)
    case mimetype
    when "image/jpeg"
      return ".jpg"
    when "image/png"
      return ".png"
    when "image/gif"
      return ".gif"
    when "video/webm"
      return ".webm"
    end
  end

  def resize(post)
    @resize = post.op? ? "250x250" : "150x150"
    @image_file.resize(@resize).format("jpg").write(@thumbpath)
    #if post.op?
    #  @image_file.resize("250x250")
    #else
    #  @image_file.resize("150x150")
    #end
    #@image_file.format(@format)
    #@image_file.write(@thumbpath)
  end

  def info
    @file_info = {
      src: @name + @format,
      thumb: @thumbname + ".jpg",
      filename: @image[:filename],
      resolution: "#{@image_file.width}&times;#{@image_file.height}",
      size: @image_file.size }
  end
end

# Functions I guess
# I could remove these making a message object and a page object because why the fuck not
def format_text(text)
  @formatter = Rouge::Formatters::HTML.new
  @lexer = Rouge::Lexers::Shell.new

  text = URI.unescape(text)
  text = text.split(/\R"""\R*/)
  text.map!.with_index do |string, counter|
    if counter.even?
      @string = HTMLEntities.new.encode(string)
      @string.gsub!(/(?<!&gt;)(&gt;&gt;)([0-9]+)/, '<a class="quotelink" href="#\2">\1\2</a>')

      @lines = @string.split(/\R/)
      @lines.map! do |line|
        line.gsub(/^(&gt;.+)$/, '<span class="quote">\1</span>')
      end
      @lines.join("<br>")
    else
      @formatter.format(@lexer.lex(string))
    end
  end
  return text.join
end

def page(imgboard, board_id, thread_id)
  @board_id = board_id
  @thread_id = thread_id

  @info = imgboard.info.find(board: board_id).to_a.first.to_h
  @boards = imgboard.boards
  @content = File.read("cache/#{board_id}/#{thread_id == 0 ? 'top' : thread_id}")

  @banner = Dir.chdir('public') do
    Dir.glob('banners/*').sample
  end

  erb :base
end
