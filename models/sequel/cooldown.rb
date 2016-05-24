class Cooldown < REM
  def initialize ip, sum = true
    ip = Digest::MD5.digest(ip) if sum
    @ip = ip
    @cooldown = @@cooldowns.where(ip: ip)
  end

  attr_accessor :ip

  def add seconds = 5
    time = Time.now + seconds
    if @cooldown.all.empty?
      @@cooldowns.insert(ip: @ip, time: time)
    elsif @cooldown.all and @cooldown.all.first[:time] < time
      @cooldown.update(time: time)
    end
  end

  def lift
    @cooldown.update(time: Time.now)
  end

  def self.include? ip, sum = true
    ip = Digest::MD5.digest(ip) if sum
    c = @@cooldowns.where(ip: ip).all
    if c.empty? or (t = c.first[:time] - Time.now) < 0
      nil
    else
      t.to_i
    end
  end
end
