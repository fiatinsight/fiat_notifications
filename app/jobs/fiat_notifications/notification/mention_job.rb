class FiatNotifications::Notification::MentionJob < ApplicationJob
  include ActionView::Helpers::TextHelper
  queue_as :default

  def perform(notifiable)
    FiatNotifications::Notification.create(recipient: User.first, creator: User.first, action: "mentioned", notifiable: notifiable)
    # Find @mentioned users and put their emails into an array
    # mentions ||= begin
    #                regex = /@([\w]+)/
    #                comment.body.scan(regex).flatten
    #              end
    # mentioned_users ||= User.where(username: mentions)
    #
    # if mentioned_users.any?
    #   mentioned_users.each do |user|
    #     Notification.create(recipient: user, user: comment.user, action: "mentioned", notifiable: comment.message)
    #
    #     if user.email_mention?
    #       if user.internal
    #         url = "https://my.fiatinsight.com/system/messages/#{comment.message.id}"
    #       elsif !user.internal
    #         url = "https://my.fiatinsight.com/client/messages/#{comment.message.id}"
    #       end
    #
    #       client = Postmark::ApiClient.new('5e054db8-4656-4b3a-923c-b3fa28c11e15')
    #       client.deliver_with_template(
    #       {:from=>"hello@fiatinsight.com",
    #        :to=>User.find(user.id).email,
    #        :reply_to=>"5dfaecfc07476ccff3b32c80c3ba592d+#{comment.message.id}@inbound.postmarkapp.com",
    #        :template_id=>1263261,
    #        :template_model=>
    #         {"commenter_name"=>User.find(comment.user.id).username,
    #          "subject"=>comment.message.subject,
    #          "body"=>simple_format(comment.body),
    #          "url"=>url,
    #          "timestamp"=>comment.created_at}}
    #       )
    #     end
    #
    #     if user.slack_mention?
    #       client = Slack::Web::Client.new
    #       link = "https://my.fiatinsight.com/system/messages/#{comment.message.id}"
    #       client.chat_postMessage(channel: "@#{user.slack_username}", text: "New comment by #{User.find(comment.user_id).username} on *#{comment.message.subject}* #{link}: #{comment.body}", as_user: false)
    #     end
    #   end
    # end
  end
end
