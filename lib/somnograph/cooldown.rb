class Cooldown < REM
  def self.format_ip ip
    ip.split(".").map { |n| "%08b" % n }.join "."
  end

  def self.update
    @@cooldowns.where('time < ?', Time.now).delete
  end

  def self.add ip, time=15
    time = Time.now + time
    @@cooldowns.insert(ip: self.format_ip(ip), time: time)
  end

  def self.lift ip
    @@cooldowns.where(ip: self.format_ip(ip)).update time: Time.now
  end

  def self.include? ip
    self.update
    not @@cooldowns.where(ip: self.format_ip(ip)).all.empty?
  end
end
