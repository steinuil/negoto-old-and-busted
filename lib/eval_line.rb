def eval_line(line)
  case line.first

  when "help"
    puts "Commands: list delete post lock unlock ban"
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
      puts "Usage: delete <board_id>[/<yarn|post_id>]"
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

  when /(un)?ban/
    @ban = line[0] == "ban"
    if line.length < 2 or line.length > 3  or line[1] == "help"
      if @ban
        puts "Usage: ban <board_id>/<yarn|post_id> [<length (in seconds)>]"
        puts "       ban <ip> [<length (in seconds)>]"
        puts "The default length is 1 year"
      else
        puts "Usage: unban <board_id>/<yarn|post_id>"
        puts "       unban <ip>"
      end
      return
    end

    if line[1] =~ /([0-9]{1,3}\.){3}[0-9]{1,3}/
      ip = line[1]
    else
      id = parse line[1]
      if id
        if id[0] == :yarn
          ip = Yarn[id[1], id[2]].ip
        elsif id[0] == :post
          ip = Post[id[1], id[2]].ip
        end
      end
    end

    secs = (line[2] and line[2].to_i) ? line[2].to_i : (60 * 60 * 24 * 365)

    if ip
      if @ban
        puts "Banning ip #{ip} for #{secs} seconds..."
        #Cooldown.add ip, secs
      else
        puts "Lifting ban on ip #{ip}..."
        #Cooldown.lift ip
      end
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
