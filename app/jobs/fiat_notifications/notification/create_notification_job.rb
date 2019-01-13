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
    email_body: nil,
    email_template_id: nil
    # Add more optional accepted parameters, here.
  )

    # First, create a notification in the db, at least...
    notification = FiatNotifications::Notification.create(notifier: notifier, creator: creator, observable: observable, action: action)

    # ...then, if it says to notify someone specific
    if notified_type && notified_ids.any?

      # Send SMS messages to anyone who should get them
      if Rails.application.credentials.twilio && Rails.application.credentials.twilio[:auth_token]
        notified_ids.each do |i|
          if notified_type.constantize.find(i).phone_number # Make sure they have a phone number
            if FiatNotifications::NotificationPreference.find_by(notifiable: notified_type.constantize.find(i), noticeable: observable) # Make sure they *want* to get an SMS message
              twilio_client = Twilio::REST::Client.new
              twilio_client.api.account.messages.create(
                from: FiatNotifications.from_phone_number,
                to: "+1#{notified_type.constantize.find(i).phone_number}",
                # body: "New notification for #{notified_type.constantize.find(i).email}: #{observable.full_name} was #{notification.action}"
                body: "#{sms_body}"
              )
            end
          end
        end
      end

      # Send emails to anyone who should get them
      if Rails.application.credentials.postmark_api_token
        notified_ids.each do |i|
          if notified_type.constantize.find(i).phone_number # Make sure they have an email address
            if FiatNotifications::NotificationPreference.find_by(notifiable: notified_type.constantize.find(i), noticeable: observable) # Make sure they *want* to get an email

              if email_template_id
                template = email_template_id
              else
                template = FiatNotifications.email_template_id
              end

              postmark_client = Postmark::ApiClient.new(Rails.application.credentials.postmark_api_token)
              postmark_client.deliver_with_template(
              {:from=>FiatNotifications.from_email_address,
               :to=>notified_type.constantize.find(i).email,
               # :reply_to=>"5dfaecfc07476ccff3b32c80c3ba592d+#{comment.message.id}@inbound.postmarkapp.com",
               :template_id=>template,
               :template_model=>
               # These are all available for your template; if you don't want to use them, that's fine!
                {"creator"=>creator_name,
                 "subject"=>"#{creator_name} #{action} #{notified_type.constantize.find(i).username}",
                 "body"=>"#{simple_format(email_body)}",
                 "url"=>"#{url}",
                 "timestamp"=>notification.created_at}}
              )
            end
          end
        end
      end

    end
  end
end
