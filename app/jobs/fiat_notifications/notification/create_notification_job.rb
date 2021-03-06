class FiatNotifications::Notification::CreateNotificationJob < FiatNotifications::ApplicationJob
  include ActionView::Helpers::TextHelper
  queue_as :default

  def perform(
    notifier,
    creator,
    observable, # These are validated
    action: nil,
    notified_type: nil,
    notified_ids: nil,
    notifier_name: nil,
    creator_name: nil,
    observable_name: nil,
    url: nil,
    sms_body: nil,
    email_subject: nil,
    email_body: nil,
    email_template_id: nil,
    reply_to_address: nil
    # Add more optional accepted parameters, here.
  )

    # First, create a notification in the db, at least...
    notification = FiatNotifications::Notification.create(notifier: notifier, creator: creator, observable: observable, action: action)

    # ...then, if it says to notify someone specific
    if notified_type && notified_ids.any?

      # Send SMS messages to anyone who should get them
      if FiatNotifications.twilio_auth_token && FiatNotifications.twilio_account_sid
        notified_ids.each do |i|
          if notified_type.constantize.find(i).phone_number # Make sure they have a phone number
            if FiatNotifications::NotificationPreference.find_by(notifiable: notified_type.constantize.find(i), noticeable: observable, sms: 1) # Make sure they *want* to get an SMS message
              twilio_client = Twilio::REST::Client.new
              twilio_client.api.account.messages.create(
                from: FiatNotifications.from_phone_number,
                to: "+1#{notified_type.constantize.find(i).phone_number}",
                body: "#{sms_body}"
              )
            end
          end
        end
      end

      # Send emails to anyone who should get them
      if FiatNotifications.postmark_api_token
        notified_ids.each do |i|
          if notified_type.constantize.find(i).email # Make sure they have an email address
            if FiatNotifications::NotificationPreference.find_by(notifiable: notified_type.constantize.find(i), noticeable: observable, email: 1) # Make sure they *want* to get an email

              if email_template_id
                template = email_template_id
              else
                template = FiatNotifications.email_template_id
              end

              postmark_client = Postmark::ApiClient.new(FiatNotifications.postmark_api_token)
              postmark_client.deliver_with_template(
              {:from=>FiatNotifications.from_email_address,
               :to=>notified_type.constantize.find(i).email,
               :reply_to=>reply_to_address,
               :template_id=>template,
               :template_model=>
               # These are all available for your template; if you don't want to use them, that's fine!
                {"creator"=>creator_name,
                 "subject"=>email_subject,
                 "body"=>"#{simple_format(email_body)}",
                 "url"=>"#{url}",
                 "timestamp"=>notification.created_at}}
              )
            end
          end
        end
      end

      # Send Slack messages to anyone who should get them
      if FiatNotifications.slack_api_token
        notified_ids.each do |i|
          if notified_type.constantize.find(i).slack_username # Make sure they have a Slack username
            if FiatNotifications::NotificationPreference.find_by(notifiable: notified_type.constantize.find(i), noticeable: observable, slack: 1) # Make sure they *want* to get a Slack message

              client = Slack::Web::Client.new
              link = "#{url}"
              client.chat_postMessage(channel: "@#{notified_type.constantize.find(i).slack_username}", text: "*#{email_subject}* #{link}: #{email_body}", as_user: false) # TODO: Sanitize HTML tags from email_body (at least)

            end
          end
        end
      end

    end
  end
end
