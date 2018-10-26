class ChangeFiatNotificationsNotifications < ActiveRecord::Migration[5.2]
  def change
    change_table :fiat_notifications_notifications do |t|
      t.rename :notifiable_type, :notifier_type
      t.rename :notifiable_id, :notifier_id
      t.rename :recipient_type, :observable_type
      t.rename :recipient_id, :observable_id
    end
  end
end
