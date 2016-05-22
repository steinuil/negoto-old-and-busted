require 'digest/md5'

class Cooldown < REM
  def self.checksum ip
    Digest::MD5.hexdigest ip
  end

  def self.update
    @@cooldowns.where('time < ?', Time.now).delete
  end

  def self.add ip, seconds = 15
    time = Time.now + seconds
    @@cooldowns.insert(ip: checksum(ip), time: time)
  end

  def self.lift ip
    @@cooldowns.where(ip: checksum(ip)).delete
  end

  def self.include? ip
    self.update
    not @@cooldowns.where(ip: checksum(ip)).all.empty?
  end

  private

  def checksup ip
    self.checksum ip
  end
end
