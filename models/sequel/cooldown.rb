require 'digest/md5'

class Cooldown < REM
  def self.checksum ip
    Digest::MD5.hexdigest ip
  end

  def self.update
    @@cooldowns.where('time < ?', Time.now).delete
  end

  def self.add ip, seconds: 5, sum: true
    time = Time.now + seconds
    ip = checksum(ip) if sum
    @@cooldowns.insert(ip: ip, time: time)
    ip
  end

  def self.lift ip_sum
    @@cooldowns.where(ip: ip_sum).delete
  end

  def self.include? ip
    self.update
    c = @@cooldowns.where(ip: checksum(ip)).all
    c.empty? ? nil : c[:time] - Time.now
  end

  private

  def checksup ip
    self.checksum ip
  end
end
