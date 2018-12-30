class FiatNotifications::Notification::CreateNotificationJob < FiatNotifications::ApplicationJob
  include ActionView::Helpers::TextHelper
  queue_as :default

  def perform(notifier, creator, observable, action, notified_type, notified_ids)

    # Create a notification in the db, at least...
    notification = FiatNotifications::Notification.create(notifier: notifier, creator: creator, observable: observable, action: action)

    if notified_type && notified_ids.any?

      # Send SMS messages to anyone who should get them
      if Rails.application.credentials.twilio_auth_token
        notified_ids.each do |i|
          if FiatNotifications::NotificationPreference.find_by(notifiable: notified_type.constantize.find(i), noticeable: observable)
            twilio_client = Twilio::REST::Client.new

            twilio_client.api.account.messages.create(
              # from: '+17032609664', # This is the phone number for Parish.es
              from: FiatNotifications.from_phone_number, # For production
              # to: '+17032200874', # For testing
              to: "+1#{User.find(i).phone_number}", # For usage
              body: "New notification for #{notified_type.constantize.find(i).email}: #{observable.full_name} was #{notification.action}"
            )
          end
        end
      end

      # Send emails to anyone who should get them
      if Rails.application.credentials.postmark_api_token
        notified_ids.each do |i|
          if FiatNotifications::NotificationPreference.find_by(notifiable: notified_type.constantize.find(i), noticeable: observable)
            postmark_client = Postmark::ApiClient.new(Rails.application.credentials.postmark_api_token)
            postmark_client.deliver_with_template(
            {:from=>FiatNotifications.from_email_address,
             :to=>notified_type.constantize.find(i).email,
             # :reply_to=>"5dfaecfc07476ccff3b32c80c3ba592d+#{comment.message.id}@inbound.postmarkapp.com",
             :template_id=>FiatNotifications.email_template_id,
             :template_model=>
              {"creator"=>creator,
               "subject"=>"New notification at #{notification.created_at}",
               "body"=>"New notification at #{notification.created_at}",
               "url"=>"https://google.com",
               "timestamp"=>notification.created_at}}
            )
          end
        end
      end

    end
  end
end
