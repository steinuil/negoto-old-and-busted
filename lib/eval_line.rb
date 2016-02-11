def eval_line(line)
  case line.first
  # List
  when "list"

    if line.length != 2
      return "Malformed command"
    end

    if line[1] == "boards"
      Board.list.map do |board|
         board[:id] << " - " << board[:name]
      end
    elsif valid? line[1]

    end
  end
end

def valid? id
  if id.empty?
    puts "No ID given"
    return false
  end

  id = id.split "/"
  if not Board.ids.include? id[0]
    puts "No such board"
    return false
  elsif id.length == 1
    return [id[0]]
  elsif id.length == 2
    if Board[id[0]].ids.include?(id[1])
    end
  else
    puts "Malformed ID"
    return false
  end
end
