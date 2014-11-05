#!/usr/bin/env ruby
require "tools"
require 'net/smtp'

class Email
  attr_reader :sender, :receiver
  attr_accessor :subject, :body

  @@tmpl = Tools::load_tmpl('email')
  @@config = Tools::load_conf('email')

  def initialize
    @smtp_server = @@config['smtp_server'] ? @@config['smtp_server'] : 'localhost'
    @sender = @@config['sender'] ? @@config['sender'] : "#{ENV['USER']}@#{ENV['HOSTNAME']}"
  end

  def validate_email(email)
    if not sender =~ /[\w_\-.]+@[\w_\-.]+/i
      raise ArgumentError.new("Invalid email address: #{sender}")
    end
  end

  def sender=(sender)
    self.validate_email(sender)
    @sender = sender
  end

  def receiver=(receiver)
    self.validate_email(receiver)
    @receiver = receiver
  end

  def send
    msg = @@tmpl % {:sender => @sender, :receiver => @receiver,
                    :subject => @subject, :body => @body}
    Net::SMTP.start(@smtp_server) do |smtp|
      smtp.send_message(msg, @sender, @receiver)
    end
  end
end
