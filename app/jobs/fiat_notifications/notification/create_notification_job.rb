class FiatNotifications::Notification::CreateNotificationJob < ApplicationJob
  include ActionView::Helpers::TextHelper
  queue_as :default

  def perform(notifier, creator, observable, action, notified_type, notified_ids)

    # Create a notification in the db, at least...
    notification = FiatNotifications::Notification.create(notifier: notifier, creator: creator, observable: observable, action: action)

    # Send SMS messages to anyone who should get them
    notified_ids.each do |i|
      if FiatNotifications::NotificationPreference.find_by(notifiable: notified_type.constantize.find(i), noticeable: observable)
        twilio_client = Twilio::REST::Client.new

        twilio_client.api.account.messages.create(
          from: '+17032609664', # This is the phone number for Parish.es
          # to: '+17032200874', # For testing
          to: "+1#{User.find(i).phone_number}", # For usage
          body: "New notification for #{notified_type.constantize.find(i).email}: #{observable.full_name} was #{notification.action}"
        )
      end
    end

    # Send emails to anyone who should get them
    notified_ids.each do |i|
      postmark_client = Postmark::ApiClient.new(Rails.application.secrets.POSTMARK_API_TOKEN)
      postmark_client.deliver_with_template(
      {:from=>"notifications@parish.es",
       :to=>User.find(i).email,
       :template_id=>8418039,
       :template_model=>
        {"subject"=>"Test notification for #{User.find(i).email}",
         "timestamp"=>notification.created_at}}
      )
    end
  end
end
