require 'net/smtp'
require 'securerandom'

class Mail
  def initialize from, to, server
    @from, @to, @server = from, to, server
    @user, @host = from.split ?@
    @recipient = to.split(?@).first
  end

  def send subject, message
    time = Time.now
    id = [
      time.to_f.*(1_000_000).to_i.to_s(36).upcase,
      SecureRandom.hex(6).upcase
    ]

    msg = <<-EOF
From: #{@user} <#{@from}>
To: #{@recipient} <#{@to}>
Subject: #{subject}
Date: #{time.strftime '%a, %d %b %Y %H:%M:%S %z (%Z)'}
Message-id: <#{id.join ?.}@#{@host}>
      
#{message}
    EOF

    begin
      conn = Net::SMTP.new @server, 25
      conn.enable_starttls
      conn.start @host do |smtp|
        smtp.send_message msg, @from, @to
      end
    rescue EOFError
      raise MailError, 'Connection closed unexpectedly'
    end
  end

  class MailError < StandardError
end
