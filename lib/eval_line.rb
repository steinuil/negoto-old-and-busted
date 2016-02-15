def eval_line(line)
  case line.first

  when "help"
    puts "Commands: list delete post lock unlock"
    puts "Help on single command: <command> help"

  # List
  when /li?st?/
    if line.length != 2 or line[1] == "help"
      puts "Usage: list <board_id>[/<yarn_id>]|boards"
      return
    end

    if line[1] == "boards"
      Board.list.each do |board|
        puts board[:id] << " - " << board[:name]
      end
    else
      id = parse line[1]
      if id
        case id[0]
        when :board
          @yarns = Board[id[1]].yarns
          if @yarns.empty?
            puts "Empty board"
          else
            @yarns.each { |yarn|
              puts "#{yarn[:id]} - #{yarn[:subject]}" }
          end
        when :yarn
          @yarn = Yarn[id[1], id[2]]
          @op = @yarn.to_hash
          puts "#{@op[:id]} - #{@op[:subject]}: #{@op[:body]}"
          @yarn.posts.each { |post|
            puts "#{post[:id]} - #{post[:body]}" }
        when :post
          puts "You selected a post"
        end
      end
    end

  # Delete
  when /del(ete)?/
    if line.length != 2 or line[1] == "help"
      puts "Usage: delete <board_id>[/<yarn_id>|<post_id>]"
      return
    end

    id = parse line[1]
    if id
      case id[0]
      when :board
        puts "Deleting /#{id[1]}/..."
        Board[id[1]].delete
      when :yarn
        puts "Deleting yarn #{id[2]} on /#{id[1]}/..."
        Yarn[id[1], id[2]].delete
      when :post
        puts "Deleting post #{id[2]} on /#{id[1]}/..."
        Post[id[1], id[2]].delete
      end
    end

  when "post"
    if line.length != 2 or line[1] == "help"
      puts "Usage: post <board_id>[/<yarn_id>]"
      puts "Raw html prompt will follow"
      return
    end

    id = parse line[1]
    if id
      post = {}

      print "body: "; post[:body] = gets.chomp
      print "spoiler (yn): "; post[:spoiler] = (gets.chomp == "y")
      if id[0] == :yarn
        print "sage (yn): "; post[:sage] = (gets.chomp == "y")
      elsif id[0] == :board
        print "subject: "; post[:subject] = gets.chomp
      end

      post[:board] = id[1]
      post[:yarn] = id[2].to_i
      post[:name] = "<span class=\"admin\">admin:steen</span>"
      post[:file] = ""

      Post.create post
    end

  when /(un)?lock/
    @lock = line[0] == "lock"
    if line.length != 2 or line[1] == "help"
      puts "Usage: [un]lock <board_id>[/<yarn_id>]"
      return
    end

    id = parse line[1]
    if id
      puts "#{@lock ? "L" : "Unl"}ocking yarn #{id[2]} on /#{id[1]}/..."
      Yarn[id[1], id[2]].locked = @lock
    end

  else
    puts "Invalid command"
  end
end

def parse id
  id = id.split "/"

  unless Board.ids.include? id[0]
    puts "No such board"
    return false
  end

  case id.length
  when 1
    return :board, id[0]
  when 2
    if Board[id[0]].yarn_ids.include? id[1].to_i
      return :yarn, id[0], id[1]
    elsif Board[id[0]].post_ids.include? id[1].to_i
      return :post, id[0], id[1]
    else
      puts "No such yarn/post"
      return false
    end
  else
    puts "Invalid ID"
    return false
  end
end
