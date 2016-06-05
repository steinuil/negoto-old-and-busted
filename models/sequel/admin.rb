class Admin < REM
  def self.[] name
    raise AdminNotFound if @@admins.where(name: name).all.empty?
    new(name)
  end

  def initialize name
    @email = name
    @admin = @@admins.where(name: name)
  end

  def create email
    @@admins.insert(
      name: @name,
      email: email,
      token: '',
      expire: Time.now)
  end

  def destroy
    @admin.delete
  end

  attr_reader :name

  def email
    @admin.map(:email).first
  end

  def token
    @admin.map(:token).first
  end

  def expire
    @admin.map(:expire).first
  end

  def expired?
    @admin.map(:expire).first < Time.now
  end

  def all
    @admin.all
  end

  def set_token token, expire
    @admin.update(token: token, expire: expire)
  end

  def invalidate_token
    @admin.update(expire: Time.now - 60)
  end

  def self.fugg!
    @@admins.update(expire: Time.now - 60)
  end
end
