class FiatNotifications::Notification::RelayJob < ApplicationJob
  queue_as :default

  def perform(notification)
    # updated_count = ApplicationController.render partial: "system/notifications/users/#{notification.action}", locals: {notification: notification}, formats: [:html]
    # ActionCable.server.broadcast "notifications:#{notification.recipient_id}", updated_count: updated_count

    list_item = ApplicationController.render partial: "system/notifications/users/list-item", locals: {notification: notification}, formats: [:html]
    ActionCable.server.broadcast "notifications:#{notification.recipient_id}", list_item: list_item
  end
end
