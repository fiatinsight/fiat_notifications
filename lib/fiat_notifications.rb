require "fiat_notifications/engine"
require 'twilio-ruby'

module FiatNotifications
  mattr_accessor :postmark_api_token
  mattr_accessor :from_email_address
  mattr_accessor :email_template_id
  mattr_accessor :reply_to_email_address
  mattr_accessor :twilio_auth_token
  mattr_accessor :twilio_account_sid
  mattr_accessor :from_phone_number
  mattr_accessor :slack_api_token
end
