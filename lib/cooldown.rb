require "set"

class Cooldown
  def self.add ip
    ip = ip.split(".").map { |n| "%08b" % n }.join(".") 
  end
end
