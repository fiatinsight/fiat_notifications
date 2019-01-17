require "fiat_notifications/engine"
require 'twilio-ruby'

module FiatNotifications
  mattr_accessor :from_email_address
  mattr_accessor :email_template_id
  mattr_accessor :reply_to_email_address
  mattr_accessor :from_phone_number
end
